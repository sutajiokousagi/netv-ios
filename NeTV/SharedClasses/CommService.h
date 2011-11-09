//
//  CommService.h
//  NeTV
//

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
