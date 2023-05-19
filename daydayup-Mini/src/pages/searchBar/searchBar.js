// pages/searchBar/searchBar.js
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
};
var taskList = [];
var App = getApp();
Page({

  /**
   * 页面的初始数据
   */
  
  data:{
    'taskSearch':[]
  },

  handleSearch(e){   
    console.log("子组件传值",e.detail)
    //包含关键词的日程
    var data = taskList;
    var taskSearch = [];
    for(var i =0;i<data.length;i++){
      console.log("data",data[i].taskName)
      console.log(data[i].taskName.indexOf(e.detail))
      if(data[i].taskName.indexOf(e.detail)>=0)
        taskSearch.push(data[i]);
    }
    this.setData({
      'taskSearch':taskSearch
    })
    console.log("taskSearch",taskSearch);
  },
  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
   
    var that = this;

    //console.log("字符串转日期", new Date("2022-03-18 12:12:12".replace(/-/g,"/")).getDate());

    //console.log("=========days=========",that.days);
    wx.getStorage({
      key: 'openid_usr',
      success(res) {
        console.log("获取到的用户名", res.data);
        var data = res.data;
        Http.asyncRequest(
          App.globalData.url+':8874/oneDayTask/getAllTasks/' + data,
          'POST', {},
          res => {
            console.log('=====findAllRoleTasks======', res.data.msg);
            if (res.data.code == 400) {
              wx.showToast({
                title: res.data.msg,
                icon: 'error',
                mask: true,
                duration: 2000
              });
            } else {
              taskList = res.data.data;
              console.log("allTaskList",taskList);
            }
          }
        )
      }
    });
    
  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady: function () {

  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function () {

  },


})