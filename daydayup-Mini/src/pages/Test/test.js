// pages/list/list.js
const App = getApp()
Page({

  /**
   * 页面的初始数据
   */
  data: {
    list:[
      {
        userId:1,
        name:'张三',
        phone:'15955040222',
        sex:'男',
        isTouchMove:false,
      },
      {
        userId: 2,
        name: '张三',
        phone: '15955040222',
        sex: '男',
        isTouchMove: false,
      },
      {
        userId: 3,
        name: '张三',
        phone: '15955040222',
        sex: '男',
        isTouchMove: false,
      },
      {
        userId: 4,
        name: '张三',
        phone: '15955040222',
        sex: '男',
        isTouchMove: false,
      },
      {
        userId: 5,
        name: '张三',
        phone: '15955040222',
        sex: '男',
        isTouchMove: false,
      },
      {
        userId: 6,
        name: '张三',
        phone: '15955040222',
        sex: '男',
        isTouchMove: false,
      },
      {
        userId: 7,
        name: '张三',
        phone: '15955040222',
        sex: '男',
        isTouchMove: false,
      },
    ]
  },
  touchstart: function (e) {
    //开始触摸时 重置所有删除
    let data = App.touch._touchstart(e, this.data.list) //将修改过的list setData
    this.setData({
      list: data
    })
  },

  //滑动事件处理
  touchmove: function (e) {
    let data = App.touch._touchmove(e, this.data.list,'userId')//将修改过的list setData
    this.setData({
      list: data
    })
  },
})