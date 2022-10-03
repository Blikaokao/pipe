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
var App = getApp();
// pages/text/index.js
Page({

    /**
     * 页面的初始数据
     */
    data: {
        taskText: '',//订单备注
        orderNoteMax: 500,//订单备注最大长度,
        dateTime1: null, //开始时间value
        dateTimeArray1: null, //开始时间数组},
        timeTrue : false,
        activityArr: [
          { id: 1, label: '提前10分钟' },
          { id: 2, label: '提前20分钟' },
          { id: 3, label: '提前30分钟' },
          { id: 4, label: '提前40分钟' },
          { id: 3, label: '提前50分钟' },
          { id: 4, label: '提前60分钟' },
        ],
        startTime:"2022-09-10 12:30",
        endTime:"2022-12-30 09:10",
        'showMenu': false,
        nav_centent: null,
        shouye: ['首页', '日程', '闹钟', '课程', '娱乐'],
        page: 0
      },  
      bindPickerChange (e) {
        console.log("e",e);
        var task = this.data.task;
        var array = this.data.activityArr;
        task.alert =array[e.detail.value].label;
        this.setData({
          setIndex: parseInt(e.detail.value),
          'task':task
        })
      }, 
    //文本     ---------     textarea
      inputs: function (e) {
          // 获取输入框的内容
          // 获取输入框的内容
            var value = e.detail.value;
            this.setData({//更新备注内容到vue缓存
              taskText: e.detail.value
            })
        // 获取输入框内容的长度
        var len = parseInt(value.length);
     
        //最少字数限制
        /*if(len <= this.data.min)
          this.setData({
            texts: "加油，够5个字可以得20积分哦"
          })
        else if(len > this.data.min)
          this.setData({
            texts: " "
          })*/
     
        //最多字数限制
        if(len > this.data.orderNoteMax) return;
        // 当输入框内容的长度大于最大长度限制（max)时，终止setData()的执行
        this.setData({
          currentWordNumber: len //当前字数
        });
      },

    /**
     * 生命周期函数--监听页面加载
     */
    byText: function(options){
      var text = this.data.taskText;
      Http.asyncRequest(
        'http://'+App.globalData.url+':8808/oneDayTask/byText',
        'POST', {
          'text':text
        },
        res => {
          if(res.data.code == 400){
            wx.showToast({
              title: '转换失败',
              icon: 'error',
              mask: true,
              duration: 1000
            });
           }
          else if(res.data.code == 200){
            wx.showToast({
              title: '提取成功',
              icon: 'success',
              mask: true,
              duration: 1000
            });
            //请求成功之后，把openid放到储存里面
            //增加类型字段
            var taskLists = res.data.data;
            for(var i = 0;i<taskLists.length;i++)
              taskLists[i].taskType = 1;
            this.setData({
              'taskLists': taskLists
            })

            var that = this;
            wx.getStorage({
              key: 'nickName',
              success(res) {
                console.log("nickName",res.data);
              
                that.setData({
                  'nickName':res.data
                })
              }
            });

            var taskLists = this.data.taskLists;
            for(var i =0;i<taskLists.length;i++)
              console.log("test for taskList"+taskLists[i]);
          }
        }
      )
      //当一个巨长的提取中  等待提取结果出现取代
      wx.showToast({
        title: '提取中...',
        icon: 'loading',
        mask: true,
        duration: 111000
      });
    },
    onLoad: function (options) {
      var windowWidth = wx.getSystemInfoSync().windowWidth;
      var windowHeight = wx.getSystemInfoSync().windowHeight;
      //rpx与px单位之间的换算 : 750/windowWidth = 屏幕的高度（rpx）/windowHeight
      var photo_height = (750*windowHeight/windowWidth)/5;
      
      var scroll_height =  (750*windowHeight/windowWidth) - photo_height;
       this.setData({
          scroll_height:scroll_height,
          photo_height:photo_height
      });
      var length = this.data.shouye.length;
      var card_width = windowWidth/length;
      var card_heigh = windowHeight/18;
    
       this.setData({
         card_width: card_width,
         card_heigh: card_heigh
      })    

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

      var that = this;
      var key = '';
      wx.getStorage({
        key: 'usr_centent_list',
        success(res) {
          console.log("photo的用户列表",res.data);
          key= res.data;
          that.setData({
            'nav_centent':key,
            'usr_centent_list':key
          })
        }
      });
    },

    change: function (event) {
      var a = event.currentTarget.dataset.pageid
      this.setData({
        page: a
      })
    },
    changepage: function (event) {
      console.log(event)
      var a = event.detail.current
      this.setData({
        page: a
      })
    },

    click_nav: function (e) {
      var that = this;
      console.log("=-====click_nav ====");
      var usr_centent_list = that.data.usr_centent_list;
      if(!that.data.showMenu){
          that.setData({
              'nav_centent' : usr_centent_list,//每点击一次就取反
              'showMenu': true,
          });
          console.log('====nav_centent===',that.data.nav_centent);
      }else{
          that.setData({
              'nav_centent' : null,//每点击一次就取反
              'showMenu': false,
          });
      }
    },
    click_item: function(e){
      console.log("=====choseitem====",e.currentTarget.dataset.choseitem);
      this.setData({
        nickName: e.currentTarget.dataset.choseitem.names
      })
      this.onLoad();
    },
    powerDrawer: function (e) {  
      var that = this
      console.log("testestest======================powerDrawer", e.currentTarget.dataset.statu);
      var currentStatu = e.currentTarget.dataset.statu;  
      
      console.log("testestest======================powerDrawer", that); 
    
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
      
        this.setData({
          startTime:startTime ,
          
          timeTrue:false
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
      
        this.setData({
          endTime:endTime,
          timeTrue:false
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
  cancel: function(e){
    console.log("========点击取消=======",e.currentTarget.dataset.pageid);
    var pagenow = this.data.page;
    var pageid = e.currentTarget.dataset.pageid;
    var taskLists = this.data.taskLists;
    for(var i = 0;i<taskLists.length;i++){
      if(i == pageid)
        taskLists.splice(i,1);
    }
    var index = pagenow == pageid ? pagenow:0;
    this.setData({
      'taskLists':taskLists,
      'index':index
    });
  },

  taskNameInput: function(e){
    var pageId = e.currentTarget.dataset.pageid;
    var taskLists = this.data.taskLists;
    var value = e.detail.value;
    if(value == null){
      console.log("=============文本内容改变===============");
    }else{
      //更改了任务的名称
      console.log("更改了任务的名称");
      taskLists[pageId].taskName = value;
      this.setData({
        'taskLists':taskLists
      })
    }
    this.setData({//更新备注内容到vue缓存
      taskText: value
    })
  },
  bindPickerChange (e) {
    console.log("改变了提醒时间e",e);
    var taskLists = this.data.taskLists;
    var page = e.currentTarget.dataset.pageid;
    var array = this.data.activityArr;
    taskLists[page].alert =(array[e.detail.value].label).slice(2,4);
    console.log("提醒时间设置",taskLists[page]);
    this.setData({
      setIndex: parseInt(e.detail.value),
      'taskLists':taskLists
    })
  },
  /***开始时间改变时出发*/
  changeStartDateTime(e) {
    let arr = e.detail.value
    let dateArr = this.data.dateTimeArray1;
    //验证开始时间不能大于结束时间
    var startTime = dateArr[0][arr[0]] + '-' + dateArr[1][arr[1]] + '-' + dateArr[2][arr[2]] + ' ' + dateArr[3][arr[3]] + ':' + dateArr[4][arr[4]]+":00";
    this.checkStartAndEndTime(startTime);
  
    var page = e.currentTarget.dataset.pageid;
    //更新一下日程
    if(this.data.timeTrue){
      var taskLists = this.data.taskLists;
      taskLists[page].startDate = startTime;

      this.setData({
        taskLists:taskLists ,
        timeTrue:false
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
    var endTime = dateArr[0][arr[0]] + '-' + dateArr[1][arr[1]] + '-' + dateArr[2][arr[2]] + ' ' + dateArr[3][arr[3]] + ':' + dateArr[4][arr[4]]+":00";
   //验证开始时间不能大于结束时间
    this.checkEndAndStartTime(endTime);
    var page = e.currentTarget.dataset.pageid;
    if(this.data.timeTrue){
      
      var taskLists = this.data.taskLists;
      taskLists[page].deadLine = endTime;

      this.setData({
        'taskLists':taskLists,
        timeTrue:false
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
  createTask: function (e) {
    //openid 和  nickName
    var taskLists = this.data.taskLists;
    var that = this;
    wx.getStorage({
      key: 'nickName',
      success(res) {
        console.log("获取到的用户名", res.data);
        var data = res.data;
        that.setData({
          'nickName': data
        })
      }
    });

    //每次重新获取一下用户
    wx.getStorage({
      key: 'openid',
      success(res) {
        console.log("获取到的用户名", res.data);
        var data = res.data;
        that.setData({
          'openid': data
        })

        Http.asyncRequest(
          'http://'+App.globalData.url+':8808/oneDayTask/createTask/' + data,
          'POST', taskLists,
          res => {
            console.log('=====createTaskResult======', res.data.msg);
            if (res.data.code == 400) {
              wx.showToast({
                title: res.data.msg,
                icon: 'error',
                mask: true,
                duration: 2000
              });
            } else {
              wx.showToast({
                title: '成功添加',
                icon: 'success',
                mask: true,
                duration: 2000,
                success: function(){
                  setTimeout(() => {
                    wx.switchTab({
                      url: '/pages/mycalen/index',
                    })
                  }, 2000);
                }
              });
            }
          }
        )

      }
    });

    //拿nickName 去找userID
    var userId = this.data.openid;
    var nickName = this.data.nickName;
    var userId;

    //获取到用户id

    for (var i = 0; i < taskLists.length; i++)
      console.log("taskLists", taskLists[i]);

    //发出请求
  },
})