var app = getApp()
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
const App = getApp();
Page({
  data: {
    navbar: ['好友', '角色'],
    currentTab: 0,
    userList: [],
    roleList: []
  },
  //初始化好友列表
  onLoad: function (options) {
    let list = JSON.parse(options.dataList)
    this.setData({
      datalist: list, 
      openid: options.openid
    })
    console.log(list,this.data.openid)
    //进行分类  好友类和角色类
    var userList = []
    var roleList = []
    for(var i = 0;i<list.length;i++){
      if(list[i].type==2)
        userList.push(list[i])
      else if(list[i].type==1)
        roleList.push(list[i])
    }
    this.setData({
      userList: userList,
      roleList: roleList
    })
    console.log("userList:",this.data.userList,"roleList:",roleList)

  },
  navbarTap: function(e){
    this.setData({
      currentTab: e.currentTarget.dataset.idx
    })
  },
  touchdelete: function (e) {
    console.log("要删除的id", e.currentTarget.dataset.idx);
    var deleteId = e.currentTarget.dataset.idx;
    var user_list = this.data.datalist;
    var new_user_list = [];
    var goalUser = {};
    for (var i = 0; i < user_list.length; i++) {
      if (user_list[i].userId != deleteId)
        new_user_list.push(user_list[i]);
      else goalUser = user_list[i];
    }

    console.log("new_user_list", new_user_list);
    this.setData({
      "datalist": new_user_list
    });

    //进行分类  好友类和角色类
    var userList = []
    var roleList = []
    for(var i = 0;i<new_user_list.length;i++){
      if(new_user_list[i].type==2)
        userList.push(new_user_list[i])
      else if(new_user_list[i].type==1)
        roleList.push(new_user_list[i])
    }
    this.setData({
      userList: userList,
      roleList: roleList
    })

    
    var deleteType = 1;
    var openid = this.data.openid;
    console.log("===要删除的好友===", goalUser)
    Http.asyncRequest(
      App.globalData.url + ':8808/fUser/deleteMiniUser/' + openid,
      'DELETE', goalUser,
      res => {
         console.log('=====deleteResult======', res.data.data);
        if (res.data.code == 200)
          wx.showToast({
            title: "成功删除",
            icon: 'success',
            duration: 2000, //持续的时间
          })
        else if (res.data.code == 400)
          wx.showToast({
            title: res.data.msg,
            icon: 'error',
            duration: 2000, //持续的时间

          })
      }
    )
  },
})