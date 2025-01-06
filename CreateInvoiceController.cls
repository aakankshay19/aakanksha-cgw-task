public class CreateInvoiceController {
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

        if(childRelationshipName == 'opportunitylineitems') {
            lineItems = [SELECT Id, Description, Count__c, Unit_Price__c FROM OpportunityLineItem WHERE OpportunityId = :originRecord];
        }
    }

    public PageReference showJson() {
        Map<String, Object> invoiceJson = new Map<String, Object>();
        invoiceJson.put('invoice_date', invoiceDate.format());
        invoiceJson.put('invoice_due_date', invoiceDueDate.format());
        invoiceJson.put('account_id', account);

        List<Map<String, Object>> lineItemList = new List<Map<String, Object>>();
        for(OpportunityLineItem item : lineItems) {
            Map<String, Object> lineItem = new Map<String, Object>();
            lineItem.put('description', item.Description);
            lineItem.put('quantity', item.Count__c);
            lineItem.put('unit_price', item.Unit_Price__c);
            lineItemList.add(lineItem);
        }

        invoiceJson.put('line_items', lineItemList);
        jsonOutput = JSON.serialize(invoiceJson);  

        PageReference page = new PageReference('/apex/ShowJsonPage');
        page.getParameters().put('jsonOutput', jsonOutput);
        return page;
    }
}
