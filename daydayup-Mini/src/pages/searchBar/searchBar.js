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
Page({

  /**
   * 页面的初始数据
   */
  
  data:{
    'taskSearch':[{
      account: "妈妈",
      alert: null,
      changeTimes: null,
      createDate: "2022-09-26T21:07:30",
      deadLine: "2022-09-28 09:00:00",
      detailtaskList: [],
      eventId: -1,
      eventType: 0,
      finishDate: null,
      id: 932,
      label: 0,
      overallProgress: "0",
      period: 0,
      startDate: "2022-09-27 08:00:00",
      taskDetailNum: 0,
      taskName: "一期报到日期",
      taskStatus: 0,
      taskType: "2",
      uniqueid: "okwj45X3X946Jox9qw5WqVyalA2s_妈妈"
    },{
      account: "妈妈",
      alert: null,
      changeTimes: null,
      createDate: "2022-09-26T21:07:30",
      deadLine: "2022-09-28 09:00:00",
      detailtaskList: [],
      eventId: -1,
      eventType: 0,
      finishDate: null,
      id: 932,
      label: 0,
      overallProgress: "0",
      period: 0,
      startDate: "2022-09-27 08:00:00",
      taskDetailNum: 0,
      taskName: "一期报到日期",
      taskStatus: 0,
      taskType: "2",
      uniqueid: "okwj45X3X946Jox9qw5WqVyalA2s_妈妈"
    }]
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
          'http://127.0.0.1:8808/oneDayTask/getAllTasks/' + data,
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