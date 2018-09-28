//
//  ViewController.m
//  IoT
//
//  Created by Lam BG on 2018/9/28.
//  Copyright © 2018年 YZ. All rights reserved.
//

#import "ViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

// 创建一个CBCentralManager成员变量作为中心
@property(nonatomic, strong) CBCentralManager * manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

#pragma mark - CBCentralManagerDelegate委托方法

//蓝牙状态改变
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    NSString * message;
    switch (central.state) {
            case 0:
            message = @"初始化中，请稍后……";
            break;
            case 1:
            message = @"设备不支持状态，过会请重试……";
            break;
            case 2:
            message = @"设备未授权状态，过会请重试……";
            break;
            case 3:
            message = @"设备未授权状态，过会请重试……";
            break;
            case 4:
            message = @"尚未打开蓝牙，请在设置中打开……";
            break;
            case 5:
            message = @"蓝牙已经成功开启，稍后……";
            break;
        default:
            break;
    }
    
    // 如果没有开启
    if (self.manager.state != CBManagerStatePoweredOn) {
        
        NSLog(@"%@", message);
    }else{
        
        // 如果已经手机开启了蓝牙，那么便扫描蓝牙硬件
        [self.manager scanForPeripheralsWithServices:nil options:nil];
    }
}

//手机蓝牙发现了一个蓝牙硬件peripheral//每发现一个蓝牙设备都会调用此函数（如果想展示搜索到得蓝牙可以逐一保存peripheral并展示）
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"发现蓝牙设备:%@",peripheral.name);//
//    if ([peripheral.name isEqual:蓝牙的名字]) {
//        self.peripheral = peripheral;
//        [self.manager connectPeripheral:self.peripheral options:nil];//如果是自己要连接的蓝牙硬件，那么进行连接
//    }
}

//返回的蓝牙服务通知通过代理实现
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService * service in peripheral.services) {
        NSLog(@"Service found with UUID :%@",service.UUID);
        //        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"18F0"]]) {
        [peripheral discoverCharacteristics:nil forService:service];
        //        }
    }
}

//查找到该设备所对应的服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    //每个peripheral都有很多服务service（这个依据蓝牙而定），每个服务都会有几个特征characteristic，区分这些就是UUID
    //这里可以利用开头说的LightBlue软件连接蓝牙看看你的蓝牙硬件有什么服务和每个服务所包含的特征，然后根据你的协议里面看看你需要用到哪个特征的哪个服务
    for (CBCharacteristic * characteristic in service.characteristics) {
        NSLog(@"查找到的服务（属性）%@",characteristic);
        //所对应的属性用于接收和发送数据
//        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2AF0"]]) {
//            [peripheral setNotifyValue:YES forCharacteristic:characteristic];//监听这个服务发来的数据
//            [peripheral readValueForCharacteristic:characteristic];//主动去读取这个服务发来的数据
//        }
//        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2AF1"]]) {
//            _characteristic = characteristic;
//            //*****此处已经连接好蓝牙，可以在这里给蓝牙发指令，也就是写入数据
//            //            [self sendMessageWithType:_type];//1.查询数量
//            例：
//            NSMutableData *value = [NSMutableData data];
//            在这里把数据转成data存储到value里面
//            NSLog(@"%@",value);
//            [_peripheral writeValue:value forCharacteristic:_characteristic type:CBCharacteristicWriteWithResponse];
//        }
    }
}

//接收数据的函数.处理蓝牙发过来得数据   读数据代理，这里已经收到了蓝牙发来的数据
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2AF0"]]) {
        NSLog(@"收到蓝牙发来的数据%@",characteristic.value);
//        NSString * string = [self hexadecimalString:characteristic.value];
        //在这里解析收到的数据，一般是data类型的数据，这里要根据蓝牙厂商提供的协议进行解析并且配合LightBlue来查看数据结构，我当时收到的数据是十六进制的数据但是是data类型，所以我先讲data解析出来之后转为十进制来使用。具体方法后面我会贴出
        //还有一点收到数据后有的硬件是需要应答的，如果应答的话就是在这里再给蓝牙发一个指令（写数据）：“我收到发的东西了，你那边要做什么操作可以做了”。
    }
}

//*****写数据代理，上面写入数据之后就会自动调用这个函数
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"%@",characteristic.UUID);
    if (error) {
        NSLog(@"Error changing notification state: %@",[error localizedDescription]);
    }
    //其实这里貌似不用些什么（我是没有写只是判断了连接状态）
}

@end
