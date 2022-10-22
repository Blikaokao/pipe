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
// pages/voice/index.js
Page({

  /**
   * 页面的初始数据
   */
  data: {
    dateTime1: null, //开始时间value
    dateTimeArray1: null, //开始时间数组},
    timeTrue: false,
    activityArr: [{
        id: 1,
        label: '10分钟'
      },
      {
        id: 2,
        label: '20分钟'
      },
      {
        id: 3,
        label: '30分钟'
      },
      {
        id: 4,
        label: '40分钟'
      },
      {
        id: 3,
        label: '50分钟'
      },
      {
        id: 4,
        label: '60分钟'
      },
    ],
    startTime: "2022-09-10 12:30",
    endTime: "2022-12-30 09:10",
    'showMenu': false,
    nav_centent: null,
    shouye: ['首页', '日程', '闹钟', '课程', '娱乐'],
    page: 0,
    cancleRecording:false

  },
  bindPickerChange(e) {
    console.log("e", e);
    var task = this.data.task;
    var array = this.data.activityArr;
    task.alert = array[e.detail.value].label;
    this.setData({
      setIndex: parseInt(e.detail.value),
      'task': task
    })
  },
  // 开始录音

  startRecording: function (e) {

    console.log('开始录音');
    this.setData({
      selectType: 'voice',
      startRecording: true,
      showVoiceMask: true
    })

    this.startVoiceRecordAnimation();
    var that = this;
    const recorderManager = wx.getRecorderManager();
    recorderManager.start({
      sampleRate: 16000,
      numberOfChannels: 1
    });

    wx.getRecorderManager().onStart(() => {
      console.log('recorder start')
    })
    //console.log("recorderManager:",this.recorderManager)
  },

  // 结束录音

  stopRecording: function (e) {

    console.log('结束录音');
    var that = this;

    const recorderManager = wx.getRecorderManager();
    recorderManager.stop();
    /*that.setData({
      selectResource: false,
      showVoiceMask: false,
      startRecording: false,
      cancleRecording: false
    })*/
    recorderManager.onStop((res) => {
      console.log('recorder stop', res)
     
      /*wx.showToast({
        title: res+"11",
        duration: 2000 //持续的时间
      })*/
    
      const {
        tempFilePath
      } = res;

      if (res.duration < 1000) {

        wx.showToast({
          title: '说话时间太短!',
          icon: 'none'
        })
        that.stopVoiceRecordAnimation();

        that.setData({
          startRecording: false,
          showVoiceMask: false
        })
        return;
      }

      if (that.data.cancleRecording == false) {

        wx.showToast({
          title: "开始调用",
          duration: 2000 //持续的时间
        })

        if (tempFilePath.length !== 0) {

          var recordLength = 0;
          if (res.duration / 1000 < 22) {
            recordLength = 160;
          } else {
            recordLength = (res.duration / 1000) / 60 * 440;
          }

          var recordTime = (res.duration / 1000).toFixed(0);
          console.log('recordLength' + recordLength);
          that.setData({

            recordingLength: recordLength,
            recordingTime: recordTime,
            voiceTempFilePath: tempFilePath,
            selectResource: true,
            showVoiceMask: false,
            startRecording: false
          })
          that.stopVoiceRecordAnimation();
          console.log("暂停1", res);
          var tempImagePath = res.tempFilePath;
          var fsm = wx.getFileSystemManager()
          var base64code = fsm.readFileSync(tempImagePath, 'base64');
          var voice = {};
          voice.len = res.fileSize;
          voice.speech = base64code;
          //console.log("voice",voiceInput);
          Http.asyncRequest(
            App.globalData.url + ':8808/oneDayTask/byVoice',
            'POST', voice,
            res => {
              console.log('=====res.data======', res.data);
              wx.showToast({
                title: res.data.msg+"1111",
              })
            }
          )
        }
      } else {
        that.setData({
          selectResource: false,
          showVoiceMask: false,
          startRecording: false,
          cancleRecording: false
        })
        that.stopVoiceRecordAnimation();

        console.log("暂停2", res);
        var tempImagePath = res.tempFilePath;
        var fsm = wx.getFileSystemManager()
        var base64code = fsm.readFileSync(tempImagePath, 'base64');
        console.log(base64code);
        var voice = {};
        //console.log("voice",res.fileSize);
        voice.len = res.fileSize;
        voice.speech = base64code;
        //console.log("voice",voiceInput);
        Http.asyncRequest(
          App.globalData.url + ':8808/oneDayTask/byVoice',
          'POST', voice,
          res => {
            console.log('=====res.data======', res.data);
            wx.showToast({
              title: res.data,
            })
          }
        )
      }
    })
  },

  //向上滑动取消录音

  moveToCancle: function (event) {

    let currentY = event.touches[0].pageY;
    if (this.data.lastVoiceYPostion !== 0) {
      if (currentY - this.data.lastVoiceYPostion < 0 && currentY < 470) {
        this.setData({
          cancleRecording: true
        })
      }
    }

    this.setData({
      lastVoiceYPostion: currentY,
      showVoiceMask: false
    })

  },

  //麦克风帧动画 

  startVoiceRecordAnimation: function () {

    var that = this;

    //话筒帧动画 
    var i = 1;
    that.data.recordAnimationSetInter = setInterval(function () {

      i++;
      i = i % 5;
      that.setData({
        recordAnimationNum: i
      })
    }, 300);

  },

  // 停止麦克风动画计时器

  stopVoiceRecordAnimation: function () {
    var that = this;
    clearInterval(that.data.recordAnimationSetInter);

  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    var windowWidth = wx.getSystemInfoSync().windowWidth;
    var windowHeight = wx.getSystemInfoSync().windowHeight;
    //rpx与px单位之间的换算 : 750/windowWidth = 屏幕的高度（rpx）/windowHeight
    var photo_height = (750 * windowHeight / windowWidth) / 5;
    var tel_width = (750 - 160) / 2;
    var tel_height = (750 * windowHeight / windowWidth - 160) / 3;
    var scroll_height = (750 * windowHeight / windowWidth) - photo_height;
    var mask_height = 750 * windowHeight / windowWidth;
    this.setData({
      scroll_height: scroll_height,
      photo_height: photo_height,
      mask_height: mask_height,
      tel_width: tel_width,
      tel_height: tel_height
    })

    var length = this.data.shouye.length;
    var card_width = windowWidth / length;
    var card_heigh = windowHeight / 18;

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
        console.log("photo的用户列表", res.data);
        key = res.data;
        that.setData({
          'nav_centent': key,
          'usr_centent_list': key
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
    if (!that.data.showMenu) {
      that.setData({
        'nav_centent': usr_centent_list, //每点击一次就取反
        'showMenu': true,
      });
      console.log('====nav_centent===', that.data.nav_centent);
    } else {
      that.setData({
        'nav_centent': null, //每点击一次就取反
        'showMenu': false,
      });
    }
  },
  click_item: function (e) {
    console.log("=====choseitem====", e.currentTarget.dataset.choseitem);
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
    if (this.data.timeTrue) {

      this.setData({
        startTime: startTime,

        timeTrue: false
      });
      wx.showToast({
        title: '成功',
        icon: 'success',
        duration: 2000 //持续的时间
      })
    } else {
      wx.showToast({
          title: '开始时间需早于结束时间！',
          icon: 'none',
          duration: 2000 //持续的时间
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
    if (this.data.timeTrue) {

      this.setData({
        endTime: endTime,
        timeTrue: false
      });
      wx.showToast({
        title: '成功',
        icon: 'success',
        duration: 2000 //持续的时间
      })
    } else {

      wx.showToast({
          title: '结束时间需晚于开始时间！',
          icon: 'none',
          duration: 2000 //持续的时间
        }),

        console.log("结束时间不能小于开始时间");
    }

  },
  checkEndAndStartTime(e) {
    var t = new Date(e.replace(/-/g, "/"));
    //有了endTime
    var end = new Date((this.data.startTime).replace(/-/g, "/"));
    if (end < t)
      this.setData({
        timeTrue: true
      });
    return;

  },
  checkStartAndEndTime(e) {
    var t = new Date(e.replace(/-/g, "/"));
    //有了endTime
    var end = new Date((this.data.endTime).replace(/-/g, "/"));
    if (end > t)
      this.setData({
        timeTrue: true
      });
    return;

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

  voiceInput: function (e) {
    // 获取输入框的内容
    var pageId = e.currentTarget.dataset.pageid;
    var taskLists = this.data.taskLists;
    var value = e.detail.value;
    if (value == null) {
      console.log("=============文本内容改变===============");
    } else {
      //更改了任务的名称
      console.log("更改了任务的名称");
      taskLists[pageId].taskName = value;
      this.setData({
        'taskLists': taskLists
      })
    }
    this.setData({ //更新备注内容到vue缓存
      taskText: value
    })
  }
})