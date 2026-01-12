({
    // Toast helper (fallbacks to alert in communities)
    toast : function(title, message, variant) {
        var t = $A.get("e.force:showToast");
        if (t) {
            t.setParams({ title: title, message: message, type: variant });
            t.fire();
        } else {
            alert(title + ': ' + message);
        }
    },
    
    // Read ONE CSV file and return mapped rows using field API names
    parseCsvFile : function(file, cb) {
        var self = this;
        var reader = new FileReader();
        reader.onload = $A.getCallback(function(){
            try {
                var text = reader.result || '';
                
                // Guard: user picked .xlsx
                var lower = (file && file.name ? file.name.toLowerCase() : '');
                if (lower && lower.slice(-5) === '.xlsx') {
                    cb('This is an .xlsx workbook. Please export as CSV and upload the .csv file.');
                    return;
                }
                
                var parsed = self.csvToRows(text); // { headers, headerSet, rows }
                
                var out = [];
                for (var r = 0; r < parsed.rows.length; r++) {
                    var rec = parsed.rows[r];
                    
                    // Map CSV -> your field API names (matches controller columns)
                    var row = {
                        __rowId: String(r + 1),
                        
                        // Booking (accepts Id or Name in CSV)
                        BookingName__c:                 self.pick(rec, ['booking id','bookingid','booking_id','booking'], ''),
                        
                        // Amount / bank / branch / etc.
                        Amount_received__c:             self.parseNumber(self.pick(rec, ['total amount','amount received','amount'], '')),
                        Payment_Received_Bank__c:                   self.pick(rec, ['bank name'], ''),
                        Branch__c:                      self.pick(rec, ['branch'], ''),
                        
                        // Transaction / mode / from
                        Check_Transaction_Nmber__c:     self.pick(rec, ['transaction number','txn number','transaction_no','transaction no'], ''),
                        Mode_of_payment__c:             self.pick(rec, ['mode of payment','payment mode','mode'], ''),
                        Payment_From__c:                self.pick(rec, ['payment from','payer'], ''),
                        
                        // Receipt date + Approval status
                        Receipt_date__c:                self.parseDateToISO(self.pick(rec, ['receipt date','created date','receipt_date'], '')),
                        Instrument_Date__c:                self.parseDateToISO(self.pick(rec, ['instrument date','instrument_date'], '')),
                        Approval_status__c:             self.pick(rec, ['approval status','status','approval'], ''),
                        Skip_Approval__c: self.parseBoolean(self.pick(rec, ['skip approval','skip','skip_approval'], ''))
                        
                        
                    };
                    
                    // Keep row if any real field has content
                    var keep = false;
                    for (var k in row) {
                        if (k === '__rowId') continue;
                        var v = row[k];
                        if (v !== null && v !== undefined && String(v).trim() !== '') { keep = true; break; }
                    }
                    if (keep) out.push(row);
                }
                
                cb(null, out);
            } catch (e) {
                cb((e && e.message) ? e.message : 'Could not parse CSV.');
            }
        });
        reader.onerror = $A.getCallback(function(){ cb('Unable to read the file.'); });
        reader.readAsText(file);
    },
    
    // ===== CSV parser (robust, ESLint-safe) =====
    csvToRows : function(text) {
        // Strip BOM
        var input = (text || '').replace(/^\uFEFF/, '');
        
        // Honor Excel "sep=;" or "sep=," directive in first line
        var sepMatch = input.match(/^(?:sep=)(.)\s*(?:\r\n|\r|\n)/i);
        var hinted = null;
        if (sepMatch && sepMatch[1]) {
            hinted = sepMatch[1];
            input = input.replace(/^(?:sep=).*(?:\r\n|\r|\n)/i, '');
        }
        
        var delim = hinted || this._detectDelimiter(input);
        var rowsRaw = this._csvScan(input, delim); // array of arrays
        
        if (!rowsRaw || !rowsRaw.length) { throw new Error('Empty CSV.'); }
        
        // Normalize headers
        function norm(s) {
            return (s || '')
            .toString()
            .trim()
            .toLowerCase()
            .replace(/\u00A0/g,' ')
            .replace(/\s+/g,' ')
            .replace(/[^a-z0-9 _-]/g,'')
            .trim();
        }
        var headersRaw = rowsRaw[0] || [];
        var headers = [];
        var headerSet = {};
        for (var h = 0; h < headersRaw.length; h++) {
            var key = norm(headersRaw[h]);
            headers.push(key);
            headerSet[key] = true;
        }
        if (!headers.length) { throw new Error('No headers found.'); }
        
        // Build objects
        var out = [];
        for (var i = 1; i < rowsRaw.length; i++) {
            var arr = rowsRaw[i] || [];
            // skip fully empty rows
            var empty = true;
            for (var j = 0; j < arr.length; j++) {
                if (String(arr[j] || '').trim() !== '') { empty = false; break; }
            }
            if (empty) continue;
            
            var obj = {};
            for (var c = 0; c < headers.length; c++) {
                obj[headers[c]] = (arr[c] !== undefined && arr[c] !== null) ? String(arr[c]).trim() : '';
            }
            out.push(obj);
        }
        
        return { headers: headers, headerSet: headerSet, rows: out };
    },
    
    _detectDelimiter : function(input) {
        var sampleLen = Math.min(input.length, 4096);
        var inQ = false, comma = 0, semi = 0;
        for (var i = 0; i < sampleLen; i++) {
            var ch = input.charAt(i);
            if (ch === '"') {
                if (inQ && input.charAt(i+1) === '"') { i++; } else { inQ = !inQ; }
            } else if (!inQ) {
                if (ch === ',') comma++;
                else if (ch === ';') semi++;
                    else if (ch === '\r' || ch === '\n') break;
            }
        }
        return (comma >= semi ? ',' : ';');
    },
    
    _csvScan : function(str, delim) {
        var rows = [], row = [], cell = '', inQ = false;
        for (var i = 0; i < str.length; i++) {
            var ch = str.charAt(i);
            if (ch === '"') {
                if (inQ && str.charAt(i+1) === '"') { cell += '"'; i++; }
                else { inQ = !inQ; }
                continue;
            }
            if (!inQ && (ch === '\r' || ch === '\n')) {
                row.push(cell); cell = ''; rows.push(row); row = [];
                if (ch === '\r' && str.charAt(i+1) === '\n') i++; // CRLF
                continue;
            }
            if (!inQ && ch === delim) {
                row.push(cell); cell = ''; continue;
            }
            cell += ch;
        }
        row.push(cell); rows.push(row);
        return rows;
    },
    
    // Utilities
    pick : function(obj, keys, defVal) {
        if (!obj) return (defVal === undefined ? '' : defVal);
        for (var i = 0; i < keys.length; i++) {
            var v = obj[keys[i]];
            if (v !== undefined && v !== null && String(v).trim() !== '') return v;
        }
        return (defVal === undefined ? '' : defVal);
    },
    
    parseNumber : function(val) {
        if (val === null || val === undefined || val === '') return null;
        var cleaned = String(val).replace(/,/g, '').trim();
        if (cleaned === '') return null;
        var n = Number(cleaned);
        return isNaN(n) ? null : n;
    },
    
    // Converts many common date strings to "YYYY-MM-DD" (Apex Date-friendly).
    // Supports: YYYY-MM-DD / YYYY/MM/DD, DD/MM/YYYY, DD-MM-YYYY, DD-MMM-YYYY,
    // and Excel serial dates (>= 25569).
    parseDateToISO : function(s) {
        if (!s) return '';
        var val = String(s).trim();
        if (!val) return '';
        
        // yyyy-mm-dd or yyyy/mm/dd
        var m = val.match(/^(\d{4})[\/\-](\d{1,2})[\/\-](\d{1,2})$/);
        if (m) return this._pad4(m[1]) + '-' + this._pad2(m[2]) + '-' + this._pad2(m[3]);
        
        // dd/mm/yyyy or dd-mm-yyyy
        m = val.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$/);
        if (m) return this._pad4(m[3]) + '-' + this._pad2(m[2]) + '-' + this._pad2(m[1]);
        
        // dd-MMM-yyyy (e.g., 01-Sep-2025)
        m = val.match(/^(\d{1,2})[\s\-]([A-Za-z]{3,})[\s\-](\d{4})$/);
        if (m) {
            var mm = this._mon2num(m[2]); if (!mm) return '';
            return this._pad4(m[3]) + '-' + this._pad2(mm) + '-' + this._pad2(m[1]);
        }
        
        // Excel serial (days since 1899-12-30)
        if (/^\d+$/.test(val)) {
            var serial = parseInt(val, 10);
            if (serial >= 25569 && serial <= 600000) {
                var epoch = new Date(Date.UTC(1899,11,30));
                var ms = epoch.getTime() + serial * 86400000;
                var d = new Date(ms);
                return d.getUTCFullYear() + '-' + this._pad2(d.getUTCMonth()+1) + '-' + this._pad2(d.getUTCDate());
            }
        }
        
        // Fallback: return as-is (Apex may still parse some forms)
        return val;
    },
    
    _pad2 : function(n){ n = parseInt(n,10); return (n<10?'0':'') + n; },
    _pad4 : function(n){ n = parseInt(n,10); var s = String(n); while (s.length<4) s = '0'+s; return s; },
    _mon2num : function(mon){
        var m = (mon||'').toLowerCase();
        var map = {jan:1,feb:2,mar:3,apr:4,may:5,jun:6,jul:7,aug:8,sep:9,oct:10,nov:11,dec:12};
        if (map[m]) return map[m];
        var full = {january:1,february:2,march:3,april:4,may:5,june:6,july:7,august:8,september:9,october:10,november:11,december:12};
        return full[m] || null;
    },
    saveRows : function(component, rows, cb) {
        var action = component.get("c.startBatchInsertReceiptLineItems");
        action.setParams({ csvList: rows }); // rows keys are Receipt__c API names
        
        action.setCallback(this, function(resp){
            var state = resp.getState();
            if (state === 'SUCCESS') {
                var jobId = resp.getReturnValue(); // AsyncApexJob Id
                
                // Clear UI on success
                component.set("v.data", []);
                component.set("v.rowCount", 0);
                component.set("v.fileName", "");
                
                // Reset the file input so the same file can be reselected if needed
                try {
                    var fi = component.find("fileInput");
                    if (fi && fi.getElement()) {
                        fi.getElement().value = null;
                    }
                } catch (e) {
                    // no-op
                }
                
                // Hand back the job id
                if (cb) cb(null, jobId);
            } else {
                var msg = 'Failed to start batch.';
                var errs = resp.getError();
                if (errs && errs[0] && errs[0].message) msg = errs[0].message;
                if (cb) cb(msg);
            }
        });
        
        $A.enqueueAction(action);
    },
    parseBoolean : function(val) {
        // already a boolean?
        if (typeof val === 'boolean') return val;
        
        var s = (val === null || val === undefined) ? '' : String(val).trim().toLowerCase();
        if (s === '') return false; // blank -> false (adjust if you prefer null)
        
        // common truthy / falsy
        var truthy = { 'true':1, 't':1, 'yes':1, 'y':1, '1':1, 'on':1, 'checked':1, 'ok':1 };
        var falsy  = { 'false':1,'f':1,'no':1,  'n':1, '0':1, 'off':1,'unchecked':1 };
        
        if (truthy[s]) return true;
        if (falsy[s])  return false;
        
        // convenience: strings starting with "skip" treated as true
        if (s.indexOf('skip') === 0) return true;
        
        // default
        return false;
    }
    
})