// custom-tab-bar/index.js
Component({
    /**
     * 组件的属性列表
     */
    properties: {
   
    },
   
    /**
     * 组件的初始数据
     */
    data: {

      half_show:false,
      isPopping: false,//是否已经弹出
      animPlus: {},//旋转动画
      animCollect: {},//item位移,透明度
      animTranspond: {},//item位移,透明度
      animInput: {},//item位移,透明度


      selected: 0,
      color: "#ffffffff",
      selectedColor: "#000000",
      listTab: [
       
        {
          pagePath: "/pages/daydayup/index",
          text: "首页",
          iconPath: "http://101.33.248.42:8051/group1/M00/00/00/rBEACmMvw-6AG3pvAAAV8CQa5tI741.png",
          selectedIconPath: "http://101.33.248.42:8051/group1/M00/00/00/rBEACmMvw-6AG3pvAAAV8CQa5tI741.png"
        },
        {
          pagePath: "/pages/index/index",
          text: "日历",
          iconPath: "http://101.33.248.42:8051/group1/M00/00/00/rBEACmMvxIGAfdVxAAAWc9E-UeU037.png",
          selectedIconPath: "http://101.33.248.42:8051/group1/M00/00/00/rBEACmMvxIGAfdVxAAAWc9E-UeU037.png"
        }
      ]
    },
  
    /**
     * 组件的方法列表
     */
    methods: {

      plus: function () {
        if (this.data.isPopping) {
            //缩回动画
            this.popp();
            this.setData({
                isPopping: false,
                half_show: true
            })
        } else if (!this.data.isPopping) {
            //弹出动画
            this.takeback();
            this.setData({
                isPopping: true,
                half_show: false
            })
        }
    },
    input: function () {
        wx.navigateTo({
          url: '../../pages/text/index',
          title: "文本添加"
        })
        console.log("input")
    },
    transpond: function () {
        wx.navigateTo({
            url: '../../pages/photo/index',
            title: "图片添加"
          })
        console.log("transpond")
    },
    collect: function () {
        wx.navigateTo({
            url: '../../pages/voice/index',
            title: "语音添加"
          })
        console.log("collect")
    },
  
    //弹出动画
    popp: function () {
        //plus顺时针旋转
        var animationPlus = wx.createAnimation({
            duration: 500,
            timingFunction: 'ease-out'
        })
        var animationcollect = wx.createAnimation({
            duration: 500,
            timingFunction: 'ease-out'
        })
        var animationTranspond = wx.createAnimation({
            duration: 500,
            timingFunction: 'ease-out'
        })
        var animationInput = wx.createAnimation({
            duration: 500,
            timingFunction: 'ease-out'
        })
        animationPlus.rotateZ(180).step();
        animationcollect.translate(69, -8).opacity(1).step();
        animationTranspond.translate(0, -55).opacity(1).step();
        animationInput.translate(-70, -8).opacity(1).step();
        this.setData({
            animPlus: animationPlus.export(),
            animCollect: animationcollect.export(),
            animTranspond: animationTranspond.export(),
            animInput: animationInput.export(),
        })
    },
    //收回动画
    takeback: function () {
        //plus逆时针旋转
        var animationPlus = wx.createAnimation({
            duration: 500,
            timingFunction: 'ease-out'
        })
        var animationcollect = wx.createAnimation({
            duration: 500,
            timingFunction: 'ease-out'
        })
        var animationTranspond = wx.createAnimation({
            duration: 500,
            timingFunction: 'ease-out'
        })
        var animationInput = wx.createAnimation({
            duration: 500,
            timingFunction: 'ease-out'
        })
        animationPlus.rotateZ(0).step();
        animationcollect.translate(0, 0).rotateZ(0).opacity(0).step();
        animationTranspond.translate(0, 0).rotateZ(0).opacity(0).step();
        animationInput.translate(0, 0).rotateZ(0).opacity(0).step();
        this.setData({
            animPlus: animationPlus.export(),
            animCollect: animationcollect.export(),
            animTranspond: animationTranspond.export(),
            animInput: animationInput.export(),
        })
    },

      switchTab(e) {
        const data = e.currentTarget.dataset;
        console.log("=========================data========",data);
        const url = data.path;
        wx.switchTab({ url });
        this.setData({
         selected: data.index
        })
      }
    }
  })