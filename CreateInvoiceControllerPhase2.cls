global class CreateInvoiceController {
    public String originRecord { get; set; }
    public String account { get; set; }
    public Date invoiceDate { get; set; }
    public Date invoiceDueDate { get; set; }
    public String childRelationshipName { get; set; }
    public String lineItemDescription { get; set; }
    public Decimal lineItemQuantity { get; set; }
    public Decimal lineItemUnitPrice { get; set; }
    public List<OpportunityLineItem> lineItems { get; set; }
    public String jsonOutput { get; set; }
    
    public CreateInvoiceController() {

        originRecord = ApexPages.currentPage().getParameters().get('origin_record');
        account = ApexPages.currentPage().getParameters().get('account');
        invoiceDate = Date.valueOf(ApexPages.currentPage().getParameters().get('invoice_date'));
        invoiceDueDate = Date.valueOf(ApexPages.currentPage().getParameters().get('invoice_due_date'));
        childRelationshipName = ApexPages.currentPage().getParameters().get('child_relationship_name');
        lineItemDescription = ApexPages.currentPage().getParameters().get('line_item_description');
        lineItemQuantity = Decimal.valueOf(ApexPages.currentPage().getParameters().get('line_item_quantity'));
        lineItemUnitPrice = Decimal.valueOf(ApexPages.currentPage().getParameters().get('line_item_unit_price'));
        
        String childRelationshipName  = ApexPages.currentPage().getParameters().get('child_relationship_name');
        
        if (childRelationshipName == 'OpportunityLineItems' && originRecord != null) {
            lineItems = [SELECT Id, Description, Count__c, Unit_Price__c 
                         FROM OpportunityLineItem 
                         WHERE OpportunityId = :originRecord];
       
    	}
    }
    
    public String generateXeroJson() {
        Map<String, Object> invoiceData = new Map<String, Object>();

        List<Map<String, Object>> lineItemsJson = new List<Map<String, Object>>();
        for (OpportunityLineItem item : lineItems) {
            Map<String, Object> lineItem = new Map<String, Object>();
            lineItem.put('Description', item.Description);
            lineItem.put('Quantity', item.Count__c);
            lineItem.put('UnitAmount', item.Unit_Price__c);
            lineItem.put('AccountCode', '200');
            lineItemsJson.add(lineItem);
        }

        invoiceData.put('LineItems', lineItemsJson);

        return JSON.serialize(invoiceData);
    }

    public void sendToXero() {
        String invoiceJson = generateXeroJson();

        String xeroApiEndpoint = 'https://api.xero.com/api.xro/2.0/Invoices';
        //String accessToken = 'your_xero_access_token';  
        //String tenantId = 'your_xero_tenant_id';  

        HttpRequest req = new HttpRequest();
        req.setEndpoint(xeroApiEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        //req.setHeader('Authorization', 'Bearer ' + accessToken);
        //req.setHeader('Xero-Tenant-Id', tenantId);
        req.setBody(invoiceJson);  

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            System.debug('created invoice in Xero: ' + res.getBody());
        } else {
            System.debug('Error creating invoice in Xero: ' + res.getBody());
        }
    }
        
}