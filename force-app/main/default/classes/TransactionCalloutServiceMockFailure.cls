/**
 * Created by Benjamin Lin on 26/6/22.
 */
@IsTest
public class TransactionCalloutServiceMockFailure implements HttpCalloutMock{
    // Implement http mock callout
    public HttpResponse respond(HttpRequest request){
        // create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('content-type', 'application/json');
        response.setStatus('Error');
        response.setStatusCode(500);
        response.setBody('FAIL');
        return response;
    }
}