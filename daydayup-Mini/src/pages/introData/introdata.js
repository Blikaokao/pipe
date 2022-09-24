import * as echarts from '../../ec-canvas/echarts';
 
function initChart(canvas, width, height, dpr) {
  const chart = echarts.init(canvas, null, {
    width: width,
    height: height,
    devicePixelRatio: dpr // new
  });
  canvas.setChart(chart);
 
  var option = {
    title: {
      text: '数据统计分析',
      left: 'center'
    },
    legend: {
      data: ['TODO', 'UNDO'],
      top: 50,
      left: 'center',
      backgroundColor: 'transparent',
      z: 100
    },
    grid: {
      containLabel: true
    },
    tooltip: {
      show: true,
      trigger: 'axis'
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
      // show: false
    },
    yAxis: {
      x: 'center',
      type: 'value',
      splitLine: {
        lineStyle: {
          type: 'dashed'
        }
      }
      // show: false
    },
    series: [{
      name: 'TODO',
      type: 'line',
      smooth: true,
      data: [8, 6, 5, 3,3, 4, 9]
    }, {
      name: 'UNDO',
      type: 'line',
      smooth: true,
      data: [2, 0, 1, 0,1, 0, 1]
    }]
  };
 
  chart.setOption(option);
  return chart;
}
function initPie(canvas, width, height, dpr) {
    const chart = echarts.init(canvas, null, {
      width: width,
      height: height,
      devicePixelRatio: dpr // new
    });
    canvas.setChart(chart);
  
    var option = {
      backgroundColor: "#ffffff",
      series: [{
        label: {
          normal: {
            fontSize: 14
          }
        },
        type: 'pie',
        center: ['50%', '50%'],
        radius: ['20%', '40%'],
        data: [{
          value: 20,
          name: '语音输入'
        }, {
          value: 55,
          name: '图片输入'
        }, {
          value: 25,
          name: '文本输入'
        }]
      }]
    };
  
    chart.setOption(option);
    return chart;
  }
  function initGraph(canvas, width, height, dpr) {
    const chart = echarts.init(canvas, null, {
      width: width,
      height: height,
      devicePixelRatio: dpr // new
    });
    canvas.setChart(chart);
  
    var option = {
      title: {
        text: ''
      },
      tooltip: {},
      animationDurationUpdate: 1500,
      animationEasingUpdate: 'quinticInOut',
      series: [
        {
          type: 'graph',
          layout: 'none',
          symbolSize: 50,
          roam: true,
          label: {
            normal: {
              show: true
            }
          },
          // edgeSymbol: ['circle', 'arrow'],
          // edgeSymbolSize: [4, 10],
          edgeLabel: {
            normal: {
              textStyle: {
                fontSize: 20
              }
            }
          },
          data: [{
            name: '我',
            x: 300,
            y: 300,
            itemStyle: {
              color: '#37A2DA'
            }
          }, {
            name: '母亲',
            x: 800,
            y: 300,
            itemStyle: {
              color: '#32C5E9'
            }
          }, {
            name: '女儿',
            x: 550,
            y: 100,
            itemStyle: {
              color: '#9FE6B8'
            }
          }, {
            name: '博主',
            x: 550,
            y: 500,
            itemStyle: {
              color: '#FF9F7F'
            }
          }],
          // links: [],
          links: [{
            source: '母亲',
            target: '我',
          }, {
            source: '我',
            target: '女儿'
          }, {
            source: '母亲',
            target: '女儿'
          }, {
            source: '母亲',
            target: '博主'
          }, {
            source: '我',
            target: '博主'
          }],
          lineStyle: {
            normal: {
              opacity: 0.9,
              width: 2,
              curveness: 0
            }
          }
        }
      ]
    };
  
    chart.setOption(option);
    return chart;
  }
  function initScatter(canvas, width, height, dpr) {
    const chart = echarts.init(canvas, null, {
      width: width,
      height: height,
      devicePixelRatio: dpr // new
    });
    canvas.setChart(chart);
  
    var data = [];
    var data2 = [];
  
    for (var i = 0; i < 10; i++) {
      data.push(
        [
          Math.round(Math.random() * 100),
          Math.round(Math.random() * 100),
          Math.round(Math.random() * 40)
        ]
      );
      data2.push(
        [
          Math.round(Math.random() * 100),
          Math.round(Math.random() * 100),
          Math.round(Math.random() * 100)
        ]
      );
    }
  
    var axisCommon = {
      axisLabel: {
        textStyle: {
          color: '#C8C8C8'
        }
      },
      axisTick: {
        lineStyle: {
          color: '#fff'
        }
      },
      axisLine: {
        lineStyle: {
          color: '#C8C8C8'
        }
      },
      splitLine: {
        lineStyle: {
          color: '#C8C8C8',
          type: 'solid'
        }
      }
    };
  
    var option = {
      backgroundColor: 'white',
      xAxis: axisCommon,
      yAxis: axisCommon,
      legend: {
        data: ['教师', '博主']
      },
      visualMap: {
        show: false,
        max: 100,
        inRange: {
          symbolSize: [20, 70]
        }
      },
      series: [{
        type: 'scatter',
        name: '教师',
        data: data
      },
      {
        name: '博主',
        type: 'scatter',
        data: data2
      }
      ],
      animationDelay: function (idx) {
        return idx * 50;
      },
      animationEasing: 'elasticOut'
    };
  
  
    chart.setOption(option);
    return chart;
  }
  
  
Page({
  onShareAppMessage: function (res) {
    return {
      title: 'ECharts 可以在微信小程序中使用啦！',
      path: '/pages/index/index',
      success: function () { },
      fail: function () { }
    }
  },
  data: {
    ec: {
      onInit: initChart
    },
    ecpie :{
      onInit: initPie
    },
    ecgraph: {
      onInit: initGraph
    },
    ecScatter: {
        onInit: initScatter
    }
  },
 
  onReady() {
  }
});