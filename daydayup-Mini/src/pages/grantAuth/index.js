// src/pages/grantAuth/index.js
var App = getApp()

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

  /**
   * 页面的初始数据
   */
  data: {
    tempFilePaths: '',
    usernm: '',

  },
  chooseimage: function chooseimage() {
    var _this = this;
    wx.chooseImage({
      count: 1, // 默认9  
      sizeType: ['original', 'compressed'], // 可以指定是原图还是压缩图，默认二者都有  
      sourceType: ['album', 'camera'], // 可以指定来源是相册还是相机，默认二者都有  
      success: function success(res) {
        wx.showToast({
          title: '正在上传...',
          icon: 'loading',
          mask: true,
          duration: 1000,
        });
      
        
        // 返回选定照片的本地文件路径列表，tempFilePath可以作为img标签的src属性显示图片  
        var tempImagePath = res.tempFilePaths;
        var fsm = wx.getFileSystemManager()
        console.log(tempImagePath[0])
        var base64code = fsm.readFileSync(tempImagePath[0], 'base64');
        console.log(base64code);
        var imageUrl = ''
        wx.uploadFile({   //微信封装的上传文件到服务器的API         
          url: App.globalData.url + ':8089/res/uploadFile',  //域名+上传文件的请求接口        
          filePath: res.tempFilePaths[0],  // tempFilePath可以作为img标签的src属性显示图片 服务器图片的路径         
          name: 'file',  //上传到服务器的参数，自定义，我定义的是image        
          header:{           
              "Content-Type":"multipart/form-data;charset=utf-8",           
              "accept":"application/json",            
              "Authorization":"Bearer .."         
           },  
           // header非必填项，具体作用见官方文档、          
            success(res) {  
            //这里的成功请求执行的内容是我们的图片上传到服务器成功 对应的是wx.uploadFile的api成功          
              
              res = JSON.parse(res.data);  
              console.log("res.data.maxHead",res.data.maxHead)          
              imageUrl = res.data.maxHead
              //imageUrl = imageUrl.split("http://101.33.248.42:8051")[1]
              console.log(imageUrl)
              _this.setData({
                
                imageUrl: imageUrl
              });
             } 
            })      
        _this.setData({
          tempFilePaths: res.tempFilePaths,
          base64code: base64code,
        })
          
        /*Http.asyncRequest(
          'http://localhost' + ':8089/res/uploadFile',
          'POST', {
            'file': tempImagePath[0]
          },
          res => {

          })*/
       
        console.log(res.tempFilePaths);
      }
      
    });
  },
  inputUsrName: function (e) {
    //console.log(e)
    console.log(e.currentTarget.dataset.current,e.detail.value)
    var that=this
    that.setData({
      usernm:e.detail.value
    })
    //console.log(that.data)
    //var value = e.detail.value;
    /**this.setData({ //更新备注内容到vue缓存
      usernm: value
    })*/
    console.log("111",this.data.usernm)
  },
  login: function () {
   
    var that = this
    console.log(that.data.imageUrl)
    var tempFilePaths = this.data.imageUrl;
    var usr = this.data.usernm
    //先对用户名进行检查
    if (usr != '') {
      //console.log(usr)
      Http.asyncRequest(
        App.globalData.url + ':8874/fUser/checkName',
        'POST', {
          'name':usr
        },
         res => {
          console.log(that.data.imageUrl)
           if(res.data.data){
            App.globalData.authUser = true;
            App.globalData.avatarUrl = that.data.imageUrl;
            App.globalData.nickName = that.data.usernm
            console.log("======", that.data.usernm);
            App.openSocket();
            wx.switchTab({
              url: '../mycalen/index',
            })
           }
        }
      )
    }
    else {
      wx.showToast({
        title: '请输入用户名',
        icon: 'none',
        duration: 1000
      })
    }
    
  }
})