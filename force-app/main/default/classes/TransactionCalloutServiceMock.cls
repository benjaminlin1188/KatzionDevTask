/**
 * Created by Benjamin Lin on 26/6/22.
 */
@IsTest
public class TransactionCalloutServiceMock implements HttpCalloutMock{
    // Implement http mock callout
    public HttpResponse respond(HttpRequest request){
        // create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('content-type', 'application/json');
        response.setStatus('OK');
        response.setStatusCode(200);
        response.setBody('Success');
        return response;
    }
}