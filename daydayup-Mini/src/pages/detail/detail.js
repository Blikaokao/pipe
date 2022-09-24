// pages/detail/detail.js
var dateTimePicker = require('../../pages/utils/dateTimePicker.js');

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
// .js
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

Page({
  
    // 已有 点击展开
    zhankai:function(e){
      // console.log(e);
      //let zk = e.currentTarget.dataset.index
      // console.log(zk);
      //let list=this.data.list;
      // console.log(list);
      //变换其打开、关闭的状态
      //zhankai = !zhankai;
      this.setData({
          zhankai: true
      })
      console.log("展开=====");
    },
    // 点击收起
    shouqi:function(e){
      // console.log(e);
      //let zk = e.currentTarget.dataset.index
      // console.log(zk);
      //let list=this.data.list;
      //变换其打开、关闭的状态
      //zhankai = false;
      this.setData({
          zhankai: false
      })
      console.log("收起====");
    },

    /**
     * 页面的初始数据
     */
    data: {
      dateTime1: null, //开始时间value
      dateTimeArray1: null, //开始时间数组},
      timeTrue : false,
      'taskId': 0,
      activityArr: [
        { id: 1, label: '提前10分钟' },
        { id: 2, label: '提前20分钟' },
        { id: 3, label: '提前30分钟' },
        { id: 4, label: '提前40分钟' },
        { id: 3, label: '提前50分钟' },
        { id: 4, label: '提前60分钟' },
      ]
    },
    bindPickerChange (e) {
      console.log("e",e);
      var task = this.data.task;
      var array = this.data.activityArr;
      task.alert =(array[e.detail.value].label).splice(2,4);
      this.setData({
        setIndex: parseInt(e.detail.value),
        updatetask: true,
        'task':task
      })
    },
    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        var that = this;
        var taskId = (function () {
            /* 获取缓存中的key，获取完之后记得立即清除缓存 */
            var key = '';
            wx.getStorage({
              key: 'taskId',
              success(res) {
                console.log(res.data);
                key= res.data;
              }
            })
            /* 清除缓存，获得之后，以免出现问题。 */
            try {
              wx.removeStorageSync('key')
            } catch (e) {
              // Do something when catch error
              console.log(e);
            }
            return key;
          }());
        console.log('这个是通过缓存获得的' + taskId);
        
        this.setData({
          'taskId':taskId
        })
       
       
          //要延时执行的代码
          Http.asyncRequest(
            'http://127.0.0.1:8808/oneDayTask/getDetailTask/'+ options.taskId,
            'POST',{},
            res => {
              var task = res.data.data;
              task.startDate = task.startDate.substr(0,16);
              task.deadLine = task.deadLine.substr(0,16);
              var detailNum = task.detailtaskList.length>0?true:false;
              that.setData({
                'task': task,
                'endTime':task.deadLine,
                'startTime':task.startDate,
                'detailNum':detailNum
              });
              console.log(that.data);
            }
          );
         
      

                
      /***此处封装称方法***/
      // 获取完整的年月日 时分秒，以及默认显示的数组
          var obj = dateTimePicker.dateTimePicker(this.data.startYear, this.data.endYear);
          var obj1 = dateTimePicker.dateTimePicker(this.data.startYear, this.data.endYear);
          // 精确到分的处理，将数组的秒去掉
          var lastArray = obj1.dateTimeArray.pop();
          var lastTime = obj1.dateTime.pop();
          this.setData({
            dateTimeArray1: obj1.dateTimeArray,
            dateTime1: obj1.dateTime,
          });


    },
  /***开始时间改变时出发*/
    changeStartDateTime(e) {
      let arr = e.detail.value
      let dateArr = this.data.dateTimeArray1;
      //验证开始时间不能大于结束时间
      var startTime = dateArr[0][arr[0]] + '-' + dateArr[1][arr[1]] + '-' + dateArr[2][arr[2]] + ' ' + dateArr[3][arr[3]] + ':' + dateArr[4][arr[4]];
      this.checkStartAndEndTime(startTime);
    
      //更新一下日程
      if(this.data.timeTrue){
        var task = this.data.task;
        task.startDate = startTime;
        this.setData({
          startTime:startTime ,
          'task':task,
          timeTrue:false,
          updatetask: true
        });  
        wx.showToast({
          title: '成功',
          icon: 'success',
          duration: 2000//持续的时间
        })
      }else{
        wx.showToast({
          title: '开始时间需早于结束时间！',
          icon: 'none',
          duration: 2000//持续的时间
        }),
      console.log("开始时间不能大于结束时间");
      }
    },
    changeEndDateTime(e) {
      let arr = e.detail.value
      let dateArr = this.data.dateTimeArray1;
      var endTime = dateArr[0][arr[0]] + '-' + dateArr[1][arr[1]] + '-' + dateArr[2][arr[2]] + ' ' + dateArr[3][arr[3]] + ':' + dateArr[4][arr[4]];
     //验证开始时间不能大于结束时间
      this.checkEndAndStartTime(endTime);
      if(this.data.timeTrue){
        var task = this.data.task;
        task.deadLine = endTime;
        this.setData({
          endTime:endTime,
          'task':task,
          timeTrue:false,
          updatetask: true
        });
        wx.showToast({
          title: '成功',
          icon: 'success',
          duration: 2000//持续的时间
        })
      }else{
       
        wx.showToast({
          title: '结束时间需晚于开始时间！',
          icon: 'none',
          duration: 2000//持续的时间
        }),

      console.log("结束时间不能小于开始时间");
      }

    },
    checkEndAndStartTime(e){
      var t = new Date(e.replace(/-/g,"/"));
      //有了endTime
        var end = new Date((this.data.startTime).replace(/-/g,"/"));
        console.log("时间比较：",t,end);
        if(end < t)
        this.setData({
          timeTrue:true 
        });
        return ;
      
    },
    checkStartAndEndTime(e) {
      var t = new Date(e.replace(/-/g,"/"));
      //有了endTime
        var end = new Date((this.data.endTime).replace(/-/g,"/"));
        if(end > t)
        this.setData({
          timeTrue:true 
        });
        return ;
      
    },
    
  /**某一列的值改变时触发*/
    changeDateTimeColumn1(e) {
      let arr = this.data.dateTime1
      let dateArr = this.data.dateTimeArray1;
      arr[e.detail.column] = e.detail.value;
      this.setData({
        startTime: dateArr[0][arr[0]] + '-' + dateArr[1][arr[1]] + '-' + dateArr[2][arr[2]] + ' ' + dateArr[3][arr[3]] + ':' + dateArr[4][arr[4]]
      });
    },
    changeEndDateTimeColumn1(e) {
      let arr = this.data.dateTime1
      let dateArr = this.data.dateTimeArray1;
      arr[e.detail.column] = e.detail.value;
      this.setData({
        endTime: dateArr[0][arr[0]] + '-' + dateArr[1][arr[1]] + '-' + dateArr[2][arr[2]] + ' ' + dateArr[3][arr[3]] + ':' + dateArr[4][arr[4]]
      });
    },
    
    submitTask: function(e){
       //要延时执行的代码
       var task= this.data.task;
       Http.asyncRequest(
        'http://127.0.0.1:8808/oneDayTask/updateTask',
        'POST',task,       
        res => {
          console.log("修改结果：",res.data);
        }
      );
      console.log("======updateTask======",this.data.task);
    }
    
})