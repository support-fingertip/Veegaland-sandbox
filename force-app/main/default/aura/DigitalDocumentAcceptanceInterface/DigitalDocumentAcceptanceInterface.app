<aura:application access="GLOBAL" extends="ltng:outApp" implements="ltng:allowGuestAccess" >
    <aura:dependency resource="c:digitalDocumentAcceptanceLWC"/>
    <aura:dependency resource="markup://lightning:openFiles" type="EVENT"/>
    <aura:dependency resource="markup://force:navigateToURL" type="EVENT"/>
</aura:application>