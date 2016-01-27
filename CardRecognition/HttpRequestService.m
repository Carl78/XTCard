//
//  HttpRequestService.m
//  YiHaiShiBei
//
//  Created by mac on 14-10-27.
//  Copyright (c) 2014年 perry. All rights reserved.
//

#import "HttpRequestService.h"

#import "AppConfig.h"

@implementation HttpRequestService

- (void)getRequestToServer:(NSString *)actionName requestPara:(NSString *)requestData success:(RequestSuccessBlock)successBlock error:(RequestErrorBlock)errorBlock
{
    NSURL *url = [NSURL URLWithString:[[OFFICIALHost stringByAppendingString:actionName] stringByAppendingString:requestData]];
#ifdef DEBUG
    NSLog(@"url is %@",url);
#endif
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    __weak ASIHTTPRequest *weekRequest = request;
    
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:10.0];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSString *responseString = [weekRequest responseString];
#ifdef DEBUG_X
        NSLog(@"success string %@",responseString);
#endif
        successBlock(responseString);
    }];
    [request setFailedBlock:^{
        NSError *error = [weekRequest error];
#ifdef DEBUG_X
        NSLog(@"error is %@",[error localizedDescription]);
#endif
        errorBlock(weekRequest.responseStatusCode, [error localizedDescription]);
    }];
    
}

- (void)postFileToServer:(NSString *)actionName Datas:(NSMutableDictionary *)datas dicParams:(NSMutableDictionary *)dicParams success:(RequestSuccessBlock)successBlock error:(RequestErrorBlock)errorBlock
{
    NSURL *url = [NSURL URLWithString:[OFFICIALHost stringByAppendingString:actionName]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    __weak ASIFormDataRequest *weekRequest = request;
    
    for (NSString *fileKey in [datas allKeys]) {
        [request addData:datas[fileKey] withFileName:@"temp.jpg" andContentType:@"image/jpeg" forKey:fileKey];
    }
    for (NSString *key in [dicParams allKeys]) {
        [request addPostValue:dicParams[key] forKey:key];
    }
    
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:30];
   
    [request startAsynchronous];
    [request setCompletionBlock:^{
#ifdef DEBUG_X
        NSLog(@"message is %@",weekRequest.responseString);
#endif
        successBlock(weekRequest.responseString);
    }];
    [request setFailedBlock:^{
#ifdef DEBUG_X
        NSLog(@"delete");
#endif
        NSError *error = [weekRequest error];
        errorBlock(weekRequest.responseStatusCode, [error localizedDescription]);
    }];
}

- (void)postRequestToServer:(NSString *)actionName dicParams:(NSMutableDictionary *)dicParams success:(RequestSuccessBlock)successBlock error:(RequestErrorBlock)errorBlock
{
    NSURL *url = [NSURL URLWithString:[OFFICIALHost stringByAppendingString:actionName]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    __weak ASIFormDataRequest *weekRequest = request;

#ifdef DEBUG_X
    NSLog(@"url is %@, dic is %@",url, dicParams);
#endif
    for (NSString *key in [dicParams allKeys]) {
        [request addPostValue:dicParams[key] forKey:key];
    }
    
    
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:30];
    [request setValidatesSecureCertificate:NO];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
#ifdef DEBUG_X
        NSLog(@"message is %@",weekRequest.responseString);
        NSLog(@"add");
#endif
        if (successBlock) {
            successBlock(weekRequest.responseString);
        }
        
    }];
    [request setFailedBlock:^{
#ifdef DEBUG_X
        NSLog(@"delete");
#endif
        NSError *error = [weekRequest error];
        errorBlock(weekRequest.responseStatusCode, [error localizedDescription]);
    }];

}

- (void)httpsRequestToServer:(NSString *)urlStr success:(RequestSuccessBlock)successBlock error:(RequestErrorBlock)errorBlock
{
    urlStr = PLISTHost;
    NSURL *url = [NSURL URLWithString:urlStr];
#ifdef DEBUG
    NSLog(@"url is %@",url);
#endif
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    __weak ASIHTTPRequest *weekRequest = request;
    
    NSData *cerFile = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mailcert" ofType:@"cer"]];
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)cerFile);
    NSArray *array = [NSArray arrayWithObjects:(__bridge id)cert,nil];
    [request setClientCertificates:array];
    [request setValidatesSecureCertificate:NO];
    
    //[request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:20.0];
    //[request setValidatesSecureCertificate:NO];
     //[request setClientCertificateIdentity:identity];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSString *responseString = [weekRequest responseString];
        NSLog(@"success string %@",responseString);

#ifdef DEBUG_X
#endif
        successBlock(responseString);
    }];
    [request setFailedBlock:^{
        NSError *error = [weekRequest error];
#ifdef DEBUG_X
        NSLog(@"error is %@",[error localizedDescription]);
#endif
        errorBlock(weekRequest.responseStatusCode, [error localizedDescription]);
    }];
    
}

@end
