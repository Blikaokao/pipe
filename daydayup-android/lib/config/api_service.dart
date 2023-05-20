import 'package:todo_list/json/all_beans.dart';
import 'package:todo_list/json/task_bean.dart';

import 'api_strategy.dart';

export 'package:dio/dio.dart';
export 'package:todo_list/json/all_beans.dart';

///这里存放所有的网络请求接口
class ApiService {
  factory ApiService() => _getInstance();

  static ApiService get instance => _getInstance();
  static ApiService _instance;

  // static final int requestSucceed = 0;
  // static final int requestFailed = 1;

  static final int requestSucceed = 200;
  static final int requestFailed = 1;

  ApiService._internal() {
    ///初始化
  }

  static ApiService _getInstance() {
    if (_instance == null) {
      _instance = new ApiService._internal();
    }
    return _instance;
  }

  // ///获取图片
  // void getPhotos({
  //   Function success,
  //   Function failed,
  //   Function error,
  //   Map<String, String> params,
  //   CancelToken token,
  //   int startPage,
  // }) {
  //   ApiStrategy.getInstance().get(
  //     "https://api.unsplash.com/photos/",
  //     (data) {
  //       if (data.toString().contains("errors")) {
  //         failed(data);
  //       } else {
  //         List<PhotoBean> beans = PhotoBean.fromMapList(data);
  //         success(beans,data);
  //       }
  //     },
  //     params: params,
  //     errorCallBack: (errorMessage) {
  //       error(errorMessage);
  //     },
  //     token: token,
  //   );
  // }
  //
  // ///提交建议(新增头像上传)
  // void postSuggestionWithAvatar(
  //     {FormData params,
  //     Function success,
  //     Function failed,
  //     Function error,
  //     CancelToken token}) {
  //   ApiStrategy.getInstance().postUpload(
  //       "fUser/oneDaySuggestion",
  //       (data) {
  //         CommonBean commonBean = CommonBean.fromMap(data);
  //         if (commonBean.status == requestSucceed) {
  //           success(commonBean);
  //         } else {
  //           failed(commonBean);
  //         }
  //       },
  //       (count, total) {},
  //       formData: params,
  //       errorCallBack: (errorMessage) {
  //         error(errorMessage);
  //       });
  // }
  //
  // ///获取建议列表
  // void getSuggestions({
  //   Function success,
  //   Function error,
  //   CancelToken token,
  // }) {
  //   ApiStrategy.getInstance().get(
  //     "fUser/getSuggestion",
  //     (data) {
  //       success(data);
  //     },
  //     errorCallBack: (errorMessage) {
  //       error(errorMessage);
  //     },
  //     token: token,
  //   );
  // }

  ///通用的请求
  void postCommon(
      {Map<String, dynamic> params,
      Function success,
      Function failed,
      Function error,
      String url,
      CancelToken token}) {
    ApiStrategy.getInstance().post(url, (data) {
      CommonBean commonBean = CommonBean.fromMap(data);
      if (commonBean.code == requestSucceed) {
        success(commonBean);
      } else {
        failed(commonBean);
      }
    }, errorCallBack: (errorMessage) {
      error(errorMessage);
    }, token: token);
  }

  ///天气获取
  void getWeatherNow({
    Function success,
    Function failed,
    Function error,
    Map<String, String> params,
    CancelToken token,
  }) {
    ApiStrategy.getInstance().get(
      "https://free-api.heweather.com/s6/weather/now",
      (data) {
        WeatherBean weatherBean = WeatherBean.fromMap(data);
        if (weatherBean.heWeather6[weatherBean.heWeather6.length - 1].status ==
            "ok") {
          success(weatherBean);
        } else {
          failed(weatherBean);
        }
      },
      params: params,
      errorCallBack: (errorMessage) {
        error(errorMessage);
      },
      token: token,
    );
  }

  ///检查更新
  void checkUpdate({
    Function success,
    Function error,
    Map<String, String> params,
    CancelToken token,
  }) {
    ApiStrategy.getInstance().post(
      "app/checkUpdate",
      (data) {
        UpdateInfoBean updateInfoBean = UpdateInfoBean.fromMap(data);
        success(updateInfoBean);
      },
      params: params,
      errorCallBack: (errorMessage) {
        error(errorMessage);
      },
      token: token,
    );
  }

  ///登录
  void login({
    Map<String, String> params,
    Function success,
    Function failed,
    Function error,
    CancelToken token,
  }) {
    ApiStrategy.getInstance().post(
        "fUser/login",
        (data) {
          LoginBean loginBean = LoginBean.fromMap(data);
          if (loginBean.code == requestSucceed) {
            success(loginBean);
          } else {
            failed(loginBean);
          }
        },
        params: params,
        errorCallBack: (errorMessage) {
          error(errorMessage);
        },
        token: token);
  }

  ///修改用户名
  void changeUserName(
      {Map<String, String> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    postCommon(
      params: params,
      success: success,
      failed: failed,
      error: error,
      url: "fUser/updateUserName",
      token: token,
    );
  }

  /*
  *
  * 查询日程
  *
  * */
  void searchCalender(
      {Map<String, String> params,
        Function success,
        Function failed,
        Function error,
        CancelToken token}) {
    postCommon(
      params: params,
      success: success,
      failed: failed,
      error: error,
      url: "oneDayTask/searchCalender",
      token: token,
    );
  }

  ///上传头像
  void uploadAvatar(
      {FormData params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().postUpload(
        "fUser/uploadAvatar",
        (data) {
          UploadAvatarBean bean = UploadAvatarBean.fromMap(data);
          if (bean.status == requestSucceed) {
            success(bean);
          } else {
            failed(bean);
          }
        },
        (count, total) {},
        formData: params,
        errorCallBack: (errorMessage) {
          error(errorMessage);
        });
  }

  ///邮箱验证码获取请求
  // void getVerifyCode({
  //   Map<String, String> params,
  //   Function success,
  //   Function failed,
  //   Function error,
  //   CancelToken token,
  // }) {
  //   postCommon(
  //     params: params,
  //     success: success,
  //     failed: failed,
  //     error: error,
  //     url: "fUser/identifyCodeSend",
  //     token: token,
  //   );
  // }

  void getVerifyCode({
    Map<String, String> params,
    Function success,
    Function failed,
    Function error,
    CancelToken token,
  }) {
    postCommon(
      success: success,
      failed: failed,
      error: error,
      url: "fUser/register/${params['phone']}",
      token: token,
    );
  }

  //邮箱验证码校验请求
  void postVerifyCheck(
      {Map<String, String> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    postCommon(
      params: params,
      success: success,
      failed: failed,
      error: error,
      url: "fUser/identifyCodeCheck",
      token: token,
    );
  }

  ///手机号注册
  void postRegister(
      {Map<String, String> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().post(
      "fUser/${params['passwd']}/${params['phone']}/${params['code']}",
      (data) {
        RegisterBean registerBean = RegisterBean.fromMap(data);
        if (registerBean.code == requestSucceed) {
          success(registerBean);
        } else {
          failed(registerBean);
        }
      },
      errorCallBack: (errorMessage) {
        error(errorMessage);
      },
      token: token,
    );
  }

  ///添加子用户
  void postCreateChild(
      {Map<String, String> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().post(
      "fUser/createChild/${params["id"]}/${params["phone"]}/${params["name"]}",
      (data) {
        RegisterBean registerBean = RegisterBean.fromMap(data);
        if (registerBean.code == requestSucceed) {
          success(registerBean.userBean);
        } else {
          failed(registerBean.userBean);
        }
      },
      errorCallBack: (errorMessage) {
        error(errorMessage);
      },
      token: token,
    );
  }

  ///添加子用户
  void postBindUser(
      {Map<String, String> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().post(
      "fUser/createrelation/${params["id"]}/${params["phone"]}/${params["name"]}",
      (data) {
        RegisterBean registerBean = RegisterBean.fromMap(data);
        if (registerBean.code == requestSucceed) {
          success(registerBean.userBean);
        } else {
          failed(registerBean.userBean);
        }
      },
      errorCallBack: (errorMessage) {
        error(errorMessage);
      },
      token: token,
    );
  }

  ///重设密码
  void postResetPassword({
    Map<String, String> params,
    Function success,
    Function failed,
    Function error,
    CancelToken token,
  }) {
    postCommon(
      params: params,
      success: success,
      failed: failed,
      error: error,
      url: "fUser/resetPassword",
      token: token,
    );
  }

  ///忘记密码
  void postForgetPassword(
      {Map<String, String> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    postCommon(
      success: success,
      failed: failed,
      error: error,
      url: " fUser/resetPassword/${params['phone']}",
      token: token,
    );
  }

  ///修改用户名
  void postResetName(
      {Map<String, dynamic> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    postCommon(
      success: success,
      failed: failed,
      error: error,
      url: "fUser/reset",
      token: token,
    );
  }

  ///上传一个Task,增
  void postCreateTask(int userId,
      {Function success,
      Function failed,
      Function error,
      CancelToken cancelToken,
      List<TaskBean> taskBeans}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/createTask/" + userId.toString(),
      (data) {
        UploadTaskBean bean = UploadTaskBean.fromMap(data);
        if (bean.status == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      params:
          List.generate(taskBeans.length, (index) => taskBeans[index].toMap()),
      errorCallBack: (errorMessage) {
        error("上传出错：$errorMessage");
      },
      token: cancelToken,
    );
  }

  ///获取所有task
  void getTasks(
      {Map<String, String> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/getTasks/" + params["id"],
      (data) {
        CloudTaskBean bean = CloudTaskBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      // params: params,
      errorCallBack: (errorMessage) {
        error("获取出错：$errorMessage");
      },
      token: token,
    );
  }

  ///获取所有task
  void getClasses(
      {Map<String, String> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/getAllClass/" + params["userId"],
      (data) {
        AllClassBean bean = AllClassBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      // params: params,
      errorCallBack: (errorMessage) {
        error("获取出错：$errorMessage");
      },
      token: token,
    );
  }

  ///获取所有task
  void getAllTasks(
      {Map<String, String> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/getAllTasks/" + params["id"],
      (data) {
        CloudTaskBean bean = CloudTaskBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      // params: params,
      errorCallBack: (errorMessage) {
        error("获取出错：$errorMessage");
      },
      token: token,
    );
  }

  ///更新一个task,改
  void postUpdateTask(
      {String token,
      Function success,
      Function failed,
      Function error,
      CancelToken cancelToken,
      TaskBean taskBean}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/updateTask",
      (data) {
        CommonBean bean = CommonBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      params: taskBean.toMap(),
      token: cancelToken,
    );
  }

  ///删除一个task，删
  void postDeleteTask(
      {Map<String, String> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    postCommon(
      // params: params,
      success: success,
      failed: failed,
      error: error,
      url: "oneDayTask/deleteTask/" + params["id"],
      token: token,
    );
  }

  ///删除一个task
  void postByVoice(
      {Map<String, dynamic> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/byVoice",
      (data) {
        EventBean bean = EventBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      params: params,
      token: token,
    );
  }

  ///文本提取
  void postByText(
      {Map<String, dynamic> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/byText",
      (data) {
        EventBean bean = EventBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      params: params,
      token: token,
    );
  }

  void postByPhoto(
      {Map<String, dynamic> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/byPhoto",
      (data) {
        EventBean bean = EventBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      params: params,
      token: token,
    );
  }

  void getClassTable(
      {Map<String, dynamic> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/byClassTask",
      (data) {
        ClassBean bean = ClassBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      params: params,
      token: token,
    );
  }

  ///得到所有任务类型
  void getAllStatus(
      {Map<String, dynamic> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) async {
    ApiStrategy.getInstance().post(
      "/oneDayTask/allStatus/${params['id']}",
      (data) {
        StatusBean bean = StatusBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      token: token,
    );
  }

  ///得到所有任务类型
  void getAllType(
      {Map<String, dynamic> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) async {
    ApiStrategy.getInstance().post(
      "oneDayTask/getAllType/${params['id']}",
      (data) {
        TaskTypeBean bean = TaskTypeBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      token: token,
    );
  }

  ///获得所有任务数量
  void getTasksCount(
      {List<int> params,
      Function success,
      Function failed,
      Function error,
      CancelToken token}) async {
    ApiStrategy.getInstance().postList(
      "oneDayTask/getTasksCount",
      (data) {
        TaskNumBean bean = TaskNumBean.fromMap(data);
        if (bean.code == requestSucceed) {
          success(bean);
        } else {
          failed(bean);
        }
      },
      params,
      token,
    );
  }
}
