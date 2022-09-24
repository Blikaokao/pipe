Page({  

  

  data: {  
    showModalStatus: false,
    data: {
      isSubmit: false,
      phone: "",
      warn:"",
      name: "",
      //表示表单现在表单内容
      location: 1,
      backgroundcolorOne: "white",
      backgroundcolorTwo: "#0899f99e"
    },
  },  

  /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady: function () {
        this.setData({
          location: 1,
          backgroundcolorOne: "#0899f95c",
          backgroundcolorTwo: "#0899f99e"
        })
    },

  changeLocationToOne: function(){
    console.log(this.data);
    this.setData({
      location: 1,
      backgroundcolorOne: "#0899f95c",
      backgroundcolorTwo: "#0899f99e"
    })
    return ;
  },
  changeLocationToTwo: function(){
    this.setData({
      location: 2,
      backgroundcolorOne: "#0899f99e",
      backgroundcolorTwo: "#0899f95c"
    })
    return ;
  },

   //做两个提交  
   /**
    * 提交需要判断
    */
  formSubmit: function (e) {
    console.log('form发生了submit事件，携带数据为：', e.detail.value);
    let { phone, name } = e.detail.value;
    if (!phone) {
      this.setData({
        warn: "手机号为空！",
        isSubmit: true
      })
      return;
    }
    this.setData({
      warn: "",
      isSubmit: true,
      phone,
      name
    })
  },


  powerDrawer: function (e) {  
    var currentStatu = e.currentTarget.dataset.statu;  
    this.util(currentStatu)  
  },  
  util: function(currentStatu){  
    /* 动画部分 */  
    // 第1步：创建动画实例   
    var animation = wx.createAnimation({  
      duration: 200,  //动画时长  
      timingFunction: "linear", //线性  
      delay: 0  //0则不延迟  
    });  
      
    // 第2步：这个动画实例赋给当前的动画实例  
    this.animation = animation;  
  
    // 第3步：执行第一组动画  
    animation.opacity(0).rotateX(-100).step();  
  
    // 第4步：导出动画对象赋给数据对象储存  
    this.setData({  
      animationData: animation.export()  
    })  
      
    // 第5步：设置定时器到指定时候后，执行第二组动画  
    setTimeout(function () {  
      // 执行第二组动画  
      animation.opacity(1).rotateX(0).step();  
      // 给数据对象储存的第一组动画，更替为执行完第二组动画的动画对象  
      this.setData({  
        animationData: animation  
      })  
        
      //关闭  
      if (currentStatu == "close") {  
        this.setData(  
          {  
            showModalStatus: false  
          }  
        );  
      }  
    }.bind(this), 200)  
    
    // 显示  
    if (currentStatu == "open") {  
      this.setData(  
        {  
          showModalStatus: true  
        }  
      );  
    }  
  }  
  
})  