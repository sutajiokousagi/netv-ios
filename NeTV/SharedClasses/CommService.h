/*
 
 File: CommService.h
 Abstract: A class to handle basic UDP communication to NeTV.

 For full documentation and source code, please visit: http://wiki.chumby.com/index.php/NeTV_developer_info
*/


#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"

@interface CommService : NSObject{
    AsyncUdpSocket *asyncSocket;
}
@property (nonatomic, retain) AsyncUdpSocket *asyncSocket;


- (id)initWithDelegate:(id)theClass;
- (id)initWithDelegate:(id)theClass andIP:(NSString *)theIP;
- (void)sendUDPCommand:(NSString *)command andParameters:(NSDictionary *)parameterDictionary andTag:(long)theTag;
- (void)sendUDPCommandWithBroadcast:(NSString *)command andParameters:(NSDictionary *)parameterDictionary andTag:(long)theTag;
- (void)sendUDPCommand:(NSString *)command andParameters:(NSDictionary *)parameterDictionary andIP:(NSString *)theIP andTag:(long)theTag;

+ (NSString*)getLocalIPAddress;

@end
