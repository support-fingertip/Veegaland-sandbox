@isTest
public class BookingFormControllerTest {
    @isTest
    public static void bookingForm(){
        
//Creating Instance for the controller
        BookingFormController bk = new BookingFormController();
        // setting values to simulate user input
        bk.aadharCardFile = Blob.valueOf('Dummy Aadhar File Content');
        bk.aadharCardFileName = 'test';
        bk.aadharNumber = '';
        bk.block = '';
        bk.carpetArea = '';
        bk.contactNumber = '7689504003';
        bk.email = 'test1@gmail.com';
        bk.facing ='';
        bk.floor = '';
        bk.occupation = '';
        bk.panCardFile = Blob.valueOf('PAN Aadhar File Content');
        bk.panCardFileName = '';
        bk.panNumber = '';
        bk.photoFile = Blob.valueOf('Dummy photo file');
        bk.photoFileName = '';
        bk.projectName ='';
        bk.unitNumber ='';
        bk.unitType ='';
        bk.sba ='';
        bk.name = '';
        
        bk.save();
        bk.submit();
        
        
        
        }

}