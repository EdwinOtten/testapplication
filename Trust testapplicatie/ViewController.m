//
//  ViewController.m
//  Trust testapplicatie
//
//  Created by Edwin on 08/06/15.
//  Copyright (c) 2015 Edwin Otten. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface ViewController ()

@end

@implementation ViewController

NSString *dataUrl = @"http://trustsmart.cloud.tilaa.com/JSON_File.txt";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateView];
}

/**
 * Get JSON from dataUrl and displays it on the screen.
 */
- (void)updateView {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // The server is returning the JSON file in text/plain format instead of application/json
    // so we need to our request manager to accept this ContentType:
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    /**
     * Execute the request.
     * If successful, pass the response to our displayJSON method.
     * If it fails, log the error.
     */
    [manager GET:dataUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self displayJSON:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

/**
 * Displays the given string on the screen.
 */
- (void)displayText:(NSString *) string {
    [_textView setText:string];
}

/**
 * Parses the given dictionary and displays it on the screen.
 */
- (void)displayJSON:(NSDictionary *)data {
    
    NSMutableString *text = [NSMutableString new];
    
    // Parse data by hardcoded keynames
    [text appendString:[self parseTrustJSON:data]];
    
    [text appendString:@"\n\n\nMaar het kan natuurlijk ook recursief, zonder de JSON keys te hardcoden:\n\n"];
    // Prase data recursively
    [text appendString:[self dictionaryToString:data]];
    
    [self displayText:text];
    
}

/**
 * Parses the given dictionary to a string by searching for hardcoded keys.
 */
- (NSMutableString *)parseTrustJSON:(NSDictionary*)dict {
    
    return [NSMutableString stringWithFormat:@"Naam: %@ \nAchternaam: %@ \nLeeftijd: %@ \nAdres: %@ \nTelefoonnummer: %@ \nFax: %@",
            dict[@"firstName"],
            dict[@"lastName"],
            dict[@"age"],
            [NSString stringWithFormat:@"%@, %@, %@, %@",
                dict[@"address"][@"streetAddress"],
                dict[@"address"][@"city"],
                dict[@"address"][@"state"],
                dict[@"address"][@"postalCode"]
            ],
            [((NSArray *)dict[@"phoneNumber"]) objectAtIndex:0][@"number"],
            [((NSArray *)dict[@"phoneNumber"]) objectAtIndex:1][@"number"]
            ];
    
}

/**
 * Parses the given dictionary to a string recursively
 */
- (NSMutableString *)dictionaryToString:(NSDictionary*)dict {
    NSMutableString *text = [NSMutableString new];
    
    for (id key in dict) {
        
        if ([dict[key] isKindOfClass:[NSDictionary class]]) {
            // If this object is a dictionary, parse it as one
            NSDictionary *embeddedDictionary = dict[key];
            [text appendString: [self dictionaryToString:embeddedDictionary]];
            
        }else if ([dict[key] isKindOfClass:[NSArray class]]) {
            // If this object is an array, treat each item as a dictionary and parse it
            NSArray *embeddedArray = dict[key];
            [text appendString: [NSString stringWithFormat:@"\n%@s: \n", key]  ];
            for (id object in embeddedArray){
                [text appendString: [self dictionaryToString:object]];
            }
            [text appendString: @"\n"];
            
        }else {
            // If this object is anything but a dictionary or array, parse it as a string
            [text appendString: [NSString stringWithFormat:@"%@: %@ \n", key, dict[key]]];
        }
        
    }
    
    return text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
