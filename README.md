# netInfo


## 概述

netInfo ，用户可以用这个模块监听网络变化和获取网络状态

## 项目地址
[github](https://github.com/weex-plugins/weex-netInfo)

## API
### `fetch(options, callback[options])`

获取当前网络状态

#### 参数

- `options {Object}`：获取网络状态时设置的参数
  - `url {number}`：测试地址,如：www.baidu.com

- `callback {function (ret)}`：执行完读取操作后的回调函数。`ret {Object}` 为 `callback` 函数的参数，有两个属性：
  - `result {string}`：结果三种类型 `success`, `cancel`, `error`
  - `info {string}`：网络状态：ios有四种：unknown,none,cell,wifi。

### `startMonitor(options, callback[options])`

监听网络状态，网络状态发生改变返回改变后的状态

#### 参数

  - `options {Object}`：监听网络时设置的参数
    - `url {number}`：测试地址,如：www.baidu.com

  - `callback {function (ret)}`：网络状态发生改变后的回调函数。`ret {Object}` 为 `callback` 函数的参数，有两个属性：
    - `result {string}`：结果三种类型 `success`, `cancel`, `error`
    - `info {string}`：网络状态：ios有四种：unknown,none,cell,wifi。

### `stopMonitor(options, callback[options])`

    关闭监听

#### 参数

      - `options {Object}`：关闭监听返回的结果
        - `url {number}`：测试地址,如：www.baidu.com

      - `callback {function (ret)}`：关闭监听后的回调函数。`ret {Object}` 为 `callback` 函数的参数，有两个属性：
        - `result {string}`：结果三种类型 `success`, `cancel`, `error`
        - `data {string}`：设置的结果，如stop。


#### 示例

```html
<template>
  <div>
      <div style="flex-direction: row; justify-content: center;">
          <wxc-button value="getStatus" size="small"  type="primary" onclick="{{getStatus}}"></wxc-button>
          <wxc-button value="startMonitor" size="small" onclick="{{startMonitor}}" type="primary" style="margin-left:20px;"></wxc-button>
          <wxc-button value="stopMonitor" size="small" onclick="{{stopMonitor}}" type="primary" style="margin-left:20px;"></wxc-button>

      </div>
    <text style="font-size:100px;">Hello World.</text>
    <textarea rows=10 style="background-color:#000;height:159;width:645;border:none;font-size:24;line-height:40;color:white;padding-left: -8px;"
              value={{info}}>
        </textarea>
  </div>
</template>

<script>
    require('weex-components');
    var netInfo = require('@weex-module/netInfo');
    module.exports = {
        data: {
            info: '',
        },
        methods: {
            getStatus:function() {
                var me = this;
                netInfo.fetch({url:'www.baidu.com'},function(ret){
                    me.info = JSON.stringify(ret)
                });
            },
            startMonitor:function() {
                var me = this;
                netInfo.startMonitor({url:'www.baidu.com'},function(ret){
                    me.info = JSON.stringify(ret)
                });

            },
            stopMonitor: function() {
                var me = this;
                netInfo.stopMonitor(function(ret){
                    me.info = JSON.stringify(ret)
                });
            },
        }
    };
</script>
```
