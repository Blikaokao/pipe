// pages/userRequest/userRequest.js
const App = getApp()
const promisic = function (func) {
    return function (params = {}) {
      return new Promise((resolve, reject) => {
        const args = Object.assign(params, {
          success: (res) => {
            resolve(res);
          },
          fail: (error) => {
            reject(error);
          }
        });
        func(args);
      });
    };
  };
  
  class Http {
    // 同步Http请求
    static async asyncRequest(url, method, data, backMethod) {
      let res = await promisic(wx.request)({
        url: url,
        method: method,
        data: data,
      })
      backMethod(res)
    }
  }
Page({

    /**
     * 页面的初始数据
     */
    data: {
        'requests':[]
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        //先赋值
        this.setData({
            'requests': App.globalData.requests
        }) 

        if(App.globalData.requests.length == 0 || App.globalData.request  == null){
          wx.showToast({
            title: "暂无好友请求",
            icon: 'error',
            duration: 2000,//持续的时间
            success:function () {
              setTimeout(function () {
                  //要延时执行的代码
                  wx.switchTab({
                    url: '../mycalen/index',
                  })
              }, 1000) //延迟时间 
            }
          })

        }

    },

    //点击同意之后发送消息到消息队列，接收消息
    //以及到接口中更新请求的状态
    agreeTap: function(e){
        console.log("agreeTap",e.currentTarget.dataset.idx)
        var id = e.currentTarget.dataset.idx;
        var userRequests = App.globalData.requests;
        var friendRequest  = {};
        for(var  i =0;i<userRequests.length;i++){
          if(userRequests[i].id == id){
            //更新消息状态
            friendRequest = userRequests[i];
            friendRequest.status = 3;
            break;
          }
        }
        console.log("======friendRequest====",friendRequest)
        Http.asyncRequest(
            'http://'+App.globalData.url+':8808/fUser/addAck',
            'POST', friendRequest,
            res => {
              if(res.data.code == 400){
                wx.showToast({
                  title: res.data.msg,
                  icon: 'error',
                  duration: 2000//持续的时间
                })
                return;
              }
                console.log("点击了接受好友请求",res.data);
                wx.showToast({
                  title: '已添加',
                  icon: 'success',
                  duration: 2000//持续的时间
                })
                //第二次发出请求 刷新页面  或者本地对请求做处理
                /**
                 * 进行本地的更新
                 */
                for(var i =0;i<userRequests.length;i++){
                  if(userRequests[i].fid == friendRequest.fid && userRequests[i].tid == friendRequest.tid)
                      userRequests[i].status = 3;
                }
                this.setData({
                  'requests': App.globalData.requests
                })
            })
    },

    refuseTap:function(){
      console.log("refuseTap",e.currentTarget.dataset.idx)
      var id = e.currentTarget.dataset.idx;
      var userRequests = App.globalData.requests;
      var friendRequest  = {};
      for(var  i =0;i<userRequests.length;i++){
        if(userRequests[i].id == id){
          friendRequest = userRequests[i];
          friendRequest.status = 2;
          userRequests[i].status = 2;
          break;
        }
      }
      
      console.log("======friendRequest====",friendRequest)
      Http.asyncRequest(
          'http://'+App.globalData.url+':8808/fUser/addAck',
          'POST', friendRequest,
          res => {
            if(res.data.code == 400){
              wx.showToast({
                title: res.data.msg,
                icon: 'error',
                duration: 2000//持续的时间
              })
              return;
            }
              console.log("点击了拒绝好友请求",res.data);
              wx.showToast({
                title: '已拒绝',
                icon: 'success',
                duration: 2000//持续的时间
              })
              this.setData({
                'requests': App.globalData.requests
              })
          })
    }
})