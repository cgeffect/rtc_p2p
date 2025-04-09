////
////  RTCObserver.m
////  RTCApp
////
////  Created by Jason on 2024/4/24.
////
//
//#import "RTCEngineNative.h"
//#include "XRTCEngineHandler.h"
//#include <sdk/objc/components/video_frame_buffer/RTCCVPixelBuffer.h>
//#include <sdk/objc/base/RTCVideoFrameBuffer.h>
//#include <sdk/objc/base/RTCMutableI420Buffer.h>
//#include <sdk/objc/base/RTCI420Buffer.h>
//#include <sdk/objc/api/video_frame_buffer/RTCNativeI420Buffer.h>
//#include <rtc_base/logging.h>
//
//#include "xrtc/media/base/media_frame.h"
//#include "xrtc/base/xrtc_json.h"
//#include "xrtc/base/xrtc_global.h"
//#include "xrtc/base/xrtc_logger.h"
//
//@interface RTCEngineNative ()
//{
//    XRTCEngineHandler _rtcEngineObserver;
//}
//@end
//
//static std::string reqAnswer(std::string url, std::string params) {
//    std::string response;
//    NSString *str = [NSString stringWithUTF8String:url.c_str()];
//    NSString *p = [NSString stringWithUTF8String:params.c_str()];
//    NSString *path = [NSString stringWithFormat:@"%@?%@", str, p];
//    NSURL *urlPath = [NSURL URLWithString:path];
//
//    __block NSString *resp = @"";
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:urlPath completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"请求出错: %@", error);
//        } else {
//            resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%@", resp);
//        }
//    }];
//    [dataTask resume];
//    
//    while (resp.length == 0) {
//        if (resp.length != 0) {
//            break;
//        }
//    }
//    return resp.UTF8String;
//}
//
//static std::string stopPush(std::string url, std::string params) {
//    std::string response;
//    NSString *str = [NSString stringWithUTF8String:url.c_str()];
//    NSString *p = [NSString stringWithUTF8String:params.c_str()];
//    NSString *path = [NSString stringWithFormat:@"%@?%@", str, p];
//    NSURL *urlPath = [NSURL URLWithString:path];
//
//    __block NSString *resp = @"";
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:urlPath completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"请求出错: %@", error);
//        } else {
//            resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%@", resp);
//        }
//    }];
//    [dataTask resume];
//    
//    while (resp.length == 0) {
//        if (resp.length != 0) {
//            break;
//        }
//    }
//    return resp.UTF8String;
//}
//
//@implementation RTCEngineNative
//{
//    std::atomic<int64_t> start_time_;
//}
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        start_time_ = 0;
//        _rtcEngineObserver.init();
//        xrtc::XRTCGlobal::Instance()->registerHttpSendAnswer(reqAnswer);
//        xrtc::XRTCGlobal::Instance()->registerHttStopPush(stopPush);
//        
//        rtc::LogMessage::LogToDebug(rtc::LoggingSeverity::LS_VERBOSE);
////        static LoggingSeverity GetLogToDebug();
//        // Sets whether logs will be directed to stderr in debug mode.
//        rtc::LogMessage::SetLogToStderr(true);
//
//    }
//    return self;
//}
//
//- (void)setup:(NSString *)json_config {
//    std::string json = json_config.UTF8String;
//    _rtcEngineObserver.Setup(json);
//}
//
//- (void)start {
//    _rtcEngineObserver.Start();
//}
//
//- (void)stop {
//    _rtcEngineObserver.Stop();
//}
//
//- (void)destroy {
//    _rtcEngineObserver.Destroy();
//}
//
//- (void)sendFrame:(RTCVideoFrame *)frame {
//
//    // 默认数据是nv12
////    RTCCVPixelBuffer *buffer = frame.buffer;
////    CVPixelBufferRef pixelBuffer = buffer.pixelBuffer;
////    //kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
////    OSType osType = CVPixelBufferGetPixelFormatType(pixelBuffer);
//    
//    RTC_OBJC_TYPE(RTCVideoFrame) *I420 = [frame newI420VideoFrame];
//    int src_width = [I420 width];
//    int src_height = [I420 height];
//    RTCI420Buffer <RTC_OBJC_TYPE(RTCVideoFrameBuffer)>*I420Buffer = I420.buffer;
//    int stridey = I420Buffer.strideY;
//    int strideu = I420Buffer.strideU;
//    int stridev = I420Buffer.strideV;
////
////    // Y + U + V
//    int size = stridey * src_height + (strideu + stridev) * ((src_height + 1) / 2);
//    std::shared_ptr<xrtc::MediaFrame> video_frame = std::make_shared<xrtc::MediaFrame>(size);
//    video_frame->fmt.media_type = xrtc::MainMediaType::kMainTypeVideo;
//    video_frame->fmt.sub_fmt.video_fmt.type = xrtc::SubMediaType::kSubTypeI420;
//    video_frame->fmt.sub_fmt.video_fmt.width = src_width;
//    video_frame->fmt.sub_fmt.video_fmt.height = src_height;
//    video_frame->stride[0] = stridey;
//    video_frame->stride[1] = strideu;
//    video_frame->stride[2] = stridev;
//    video_frame->data_len[0] = stridey * src_height;
//    video_frame->data_len[1] = strideu * ((src_height + 1) / 2);
//    video_frame->data_len[2] = stridev * ((src_height + 1) / 2);
//    video_frame->data[1] = video_frame->data[0] + video_frame->data_len[0];
//    video_frame->data[2] = video_frame->data[1] + video_frame->data_len[1];
//
//    memcpy(video_frame->data[0], I420Buffer.dataY, video_frame->data_len[0]);
//    memcpy(video_frame->data[1], I420Buffer.dataU, video_frame->data_len[1]);
//    memcpy(video_frame->data[2], I420Buffer.dataV, video_frame->data_len[2]);
//
//    int64_t captureTimeStampMs = frame.timeStampNs / 1000;
//    if (0 == start_time_) {
//        start_time_ = captureTimeStampMs;
//    }
//
//    video_frame->ts = static_cast<uint32_t>(captureTimeStampMs - start_time_);
//    video_frame->capture_time_ms = captureTimeStampMs;
//    
//    _rtcEngineObserver.OnFrame(video_frame);
//}
//
//- (void)startPush:(NSString *)url {
//
////    XRTC_DLOG("%s", "111");
//    NSString *urlString = @"http://www.str2num.com/signaling/push?uid=1024&streamName=xrtc1024&audio=1&video=1&isDtls=0";
//    NSString *xrtcString = @"xrtc://www.str2num.com/push?uid=1024&streamName=xrtc1024&audio=1&video=1&isDtls=0";
//    NSURL *urlPath = [NSURL URLWithString:urlString];
//
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:urlPath completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"请求出错: %@", error);
//        } else {
//            NSString *sdpStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%@", sdpStr);
//            
//            std::map<std::string, xrtc::JsonValue> mapObj;
//            xrtc::JsonValue urlVal = xrtc::JsonValue(urlString.UTF8String);
//            xrtc::JsonValue sdpVal = xrtc::JsonValue(sdpStr.UTF8String);
//            mapObj["url"] = urlVal;
//            mapObj["sdp"] = sdpVal;
//            xrtc::JsonObject jsonObj = xrtc::JsonObject(mapObj);
//
//            xrtc::JsonValue objVal = xrtc::JsonValue(jsonObj);
//            std::string jsonStr = objVal.ToJson();
//            self->_rtcEngineObserver.startPush(xrtcString.UTF8String, sdpStr.UTF8String);
//        }
//    }];
//    [dataTask resume];
//}
//
//@end
///*
// {
//     "errNo": 0,
//     "errMsg": "success",
//     "data": {
//         "type": "offer",
//         "sdp": "v=0\r\no=- 0 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE audio video\r\na=msid-semantic: WMS\r\nm=audio 9 RTP/SAVPF 111\r\nc=IN IP4 0.0.0.0\r\na=rtcp:9 IN IP4 0.0.0.0\r\na=candidate:3368696143 1 udp 2113937151 115.29.102.225 12193 typ host\r\na=ice-ufrag:Ztlk\r\na=ice-pwd:Cb3PawOHowKlWBx+QUS3iWL0\r\na=mid:audio\r\na=recvonly\r\na=rtcp-mux\r\na=rtpmap:111 opus/48000/2\r\na=rtcp-fb:111 transport-cc\r\na=fmtp:111 minptime=10;useinbandfec=1\r\nm=video 9 RTP/SAVPF 107 99\r\nc=IN IP4 0.0.0.0\r\na=rtcp:9 IN IP4 0.0.0.0\r\na=ice-ufrag:Ztlk\r\na=ice-pwd:Cb3PawOHowKlWBx+QUS3iWL0\r\na=mid:video\r\na=recvonly\r\na=rtcp-mux\r\na=rtpmap:107 H264/90000\r\na=rtcp-fb:107 goog-remb\r\na=rtcp-fb:107 transport-cc\r\na=rtcp-fb:107 ccm fir\r\na=rtcp-fb:107 nack\r\na=rtcp-fb:107 nack pli\r\na=fmtp:107 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f\r\na=rtpmap:99 rtx/90000\r\na=fmtp:99 apt=107\r\n"
//     }
// }
// */
