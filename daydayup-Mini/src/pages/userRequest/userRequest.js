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
        'requests':[1]
    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        //先赋值
        this.setData({
            'requests': App.globalData.requests
        }) 

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
            friendRequest = userRequests[i];
            break;
          }
        }
        friendRequest.status = 3;
        console.log("======friendRequest====",friendRequest)
        Http.asyncRequest(
            'http://localhost:8808/fUser/addAck',
            'POST', friendRequest,
            res => {
                console.log("点击了接受好友请求",res.data);
                wx.showToast({
                  title: '已添加',
                  icon: 'success',
                  duration: 2000//持续的时间
                })
            })
    },

    refuseTap:function(){
      console.log("agreeTap",e.currentTarget.dataset.idx)
      var id = e.currentTarget.dataset.idx;
      var userRequests = App.globalData.requests;
      var friendRequest  = {};
      for(var  i =0;i<userRequests.length;i++){
        if(userRequests[i].id == id){
          friendRequest = userRequests[i];
          break;
        }
      }
      friendRequest.status = 2;
      console.log("======friendRequest====",friendRequest)
      Http.asyncRequest(
          'http://localhost:8808/fUser/addAck',
          'POST', friendRequest,
          res => {
              console.log("点击了拒绝好友请求",res.data);
              wx.showToast({
                title: '已拒绝',
                icon: 'fail',
                duration: 2000//持续的时间
              })
          })
    }
})