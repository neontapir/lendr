package com.agilechuckwagon.lendr.io;

/**
 * Created by Chuck Durfee on 3/2/18.
 */

import com.google.api.client.auth.oauth.OAuthAuthorizeTemporaryTokenUrl;
import com.google.api.client.auth.oauth.OAuthCredentialsResponse;
import com.google.api.client.auth.oauth.OAuthGetAccessToken;
import com.google.api.client.auth.oauth.OAuthGetTemporaryToken;
import com.google.api.client.auth.oauth.OAuthHmacSigner;
import com.google.api.client.auth.oauth.OAuthParameters;
import com.google.api.client.http.GenericUrl;
import com.google.api.client.http.HttpRequestFactory;
import com.google.api.client.http.HttpResponse;
import com.google.api.client.http.apache.ApacheHttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;

import java.io.IOException;

/**
 * Author: davecahill
 * Source: https://github.com/davecahill/goodreads-oauth-sample
 *
 * Adapted from user Sqeezer's StackOverflow post at
 * http://stackoverflow.com/questions/15194182/examples-for-oauth1-using-google-api-java-oauth
 * to work with Goodreads' oAuth API.
 *
 * Get a key / secret by registering at https://www.goodreads.com/api/keys
 * and replace YOUR_KEY_HERE / YOUR_SECRET_HERE in the code below.
 */
public class GoodreadsOAuthHandler {

    public static final String BASE_GOODREADS_URL = "https://www.goodreads.com";
    public static final String TOKEN_SERVER_URL = BASE_GOODREADS_URL + "/oauth/request_token";
    public static final String AUTHENTICATE_URL = BASE_GOODREADS_URL + "/oauth/authorize";
    public static final String ACCESS_TOKEN_URL = BASE_GOODREADS_URL + "/oauth/access_token";

    // TODO: Store secrets in something more robust that environmental variables
    public static final String GOODREADS_KEY = System.getenv("GOODREADS_KEY");
    public static final String GOODREADS_SECRET = System.getenv("GOODREADS_SECRET");

    public static String authorizeAndGet() throws IOException, InterruptedException {
        OAuthHmacSigner signer = new OAuthHmacSigner();
        OAuthCredentialsResponse temporaryTokenResponse = getTemporaryToken(signer);
        String authUrl = buildAuthenticateUrl(temporaryTokenResponse);
        getVerifierCode(authUrl);
        OAuthCredentialsResponse accessTokenResponse = getAccessToken(signer, temporaryTokenResponse);
        OAuthParameters oauthParameters = buildOAuthParameters(signer, accessTokenResponse);
        return accessResourceUrl(oauthParameters);
    }

    private static String accessResourceUrl(OAuthParameters oauthParameters) throws IOException {
        // Use OAuthParameters to access the desired Resource URL
        HttpRequestFactory requestFactory = new ApacheHttpTransport().createRequestFactory(oauthParameters);
        GenericUrl genericUrl = new GenericUrl("https://www.goodreads.com/api/auth_user");
        HttpResponse resp = requestFactory.buildGetRequest(genericUrl).execute();
        System.out.println(resp.parseAsString());
        return resp.parseAsString();
    }

    private static OAuthParameters buildOAuthParameters(OAuthHmacSigner signer, OAuthCredentialsResponse accessTokenResponse) {
        // Build OAuthParameters in order to use them while accessing the resource
        OAuthParameters oauthParameters = new OAuthParameters();
        signer.tokenSharedSecret = accessTokenResponse.tokenSecret;
        oauthParameters.signer = signer;
        oauthParameters.consumerKey = GOODREADS_KEY;
        oauthParameters.token = accessTokenResponse.token;
        return oauthParameters;
    }

    private static OAuthCredentialsResponse getAccessToken(OAuthHmacSigner signer, OAuthCredentialsResponse temporaryTokenResponse) throws IOException {
        // Get Access Token using Temporary token and Verifier Code
        OAuthGetAccessToken getAccessToken = new OAuthGetAccessToken(ACCESS_TOKEN_URL);
        getAccessToken.signer = signer;
        // NOTE: This is the main difference from the StackOverflow example
        signer.tokenSharedSecret = temporaryTokenResponse.tokenSecret;
        getAccessToken.temporaryToken = temporaryTokenResponse.token;
        getAccessToken.transport = new NetHttpTransport();
        getAccessToken.consumerKey = GOODREADS_KEY;
        return getAccessToken.execute();
    }

    private static void getVerifierCode(String authUrl) throws InterruptedException {
        // Redirect to Authenticate URL in order to get Verifier Code
        System.out.println("Goodreads oAuth sample: Please visit the following URL to authorize:");
        System.out.println(authUrl);
        System.out.println("Waiting 10s to allow time for visiting auth URL and authorizing...");
        Thread.sleep(10000);

        System.out.println("Waiting time complete - assuming access granted and attempting to get access token");
    }

    private static String buildAuthenticateUrl(OAuthCredentialsResponse temporaryTokenResponse) {
        // Build Authenticate URL
        OAuthAuthorizeTemporaryTokenUrl accessTempToken = new OAuthAuthorizeTemporaryTokenUrl(AUTHENTICATE_URL);
        accessTempToken.temporaryToken = temporaryTokenResponse.token;
        return accessTempToken.build();
    }

    private static OAuthCredentialsResponse getTemporaryToken(OAuthHmacSigner signer) throws IOException {
        // Get Temporary Token
        OAuthGetTemporaryToken getTemporaryToken = new OAuthGetTemporaryToken(TOKEN_SERVER_URL);
        signer.clientSharedSecret = GOODREADS_SECRET;
        getTemporaryToken.signer = signer;
        getTemporaryToken.consumerKey = GOODREADS_KEY;
        getTemporaryToken.transport = new NetHttpTransport();
        return getTemporaryToken.execute();
    }
}