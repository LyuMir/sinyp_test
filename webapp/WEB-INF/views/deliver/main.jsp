<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
  <% %>
<meta charset="utf-8">
<title>배달하기 메인페이지 </title>

<script type="text/javascript" src="https://openapi.map.naver.com/openapi/v3/maps.js?ncpClientId=thdo2oxpth&submodules=geocoder"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

</head>
<body>
<button type="button" name="button" onclick="location.href='index'">메인으로 돌아가기</button>

<div id="map" style="width:100%;height:400px;">
  <div class="buttons" style="z-index: 100; position:absolute;top: 20px;    left: 20px;">
      <input id="traffic" type="button" value="교통상황 켜기/끄기" class="control-btn">
  </div>
  <div class="search" style="z-index: 100; position:absolute;   top: 40px;    left: 20px;">
      <input id="address" type="text" placeholder="검색할 주소" value="강남">
      <input id="submit" type="button" value="주소 검색">
  </div>
</div>

    <script type="text/javascript">

    var mapOptions = {
          center: new naver.maps.LatLng(126.7637297, 37.5045109),
          zoom: 10,
          mapTypeControl: true,
          mapTypeControlOptions: {
              style: naver.maps.MapTypeControlStyle.DROPDOWN
          }
      }
    var map = new naver.maps.Map('map', {
        center: new naver.maps.LatLng(126.7637297, 37.5045109),
        zoom: 10
    });
    var trafficLayer = new naver.maps.TrafficLayer({
        interval: 300000 // 5분마다 새로고침 (최소값 5분)
    });
    var position00 = new naver.maps.LatLng(126.7637297,37.5045109);
    var marker09 = new naver.maps.Marker({
            position:position00,
            map: map
    });

    //여기가 실시간 교통
    var btn = $('#traffic');

    naver.maps.Event.addListener(map, 'trafficLayer_changed', function(trafficLayer) {
        if (trafficLayer) {
            btn.addClass('control-on');
            $("#autorefresh").parent().show();
            $("#autorefresh")[0].checked = true;
        } else {
            btn.removeClass('control-on');
            $("#autorefresh").parent().hide();
        }
    });

    btn.on("click", function(e) {
        e.preventDefault();

        if (trafficLayer.getMap()) {
            trafficLayer.setMap(null);
        } else {
            trafficLayer.setMap(map);
        }
    });

    $("#autorefresh").on("click", function(e) {
        var btn = $(this),
            checked = btn.is(":checked");

        if (checked) {
            trafficLayer.startAutoRefresh();
        } else {
            trafficLayer.endAutoRefresh();
        }
    });

    naver.maps.Event.once(map, 'init_stylemap', function() {
        trafficLayer.setMap(map);
    });

        // 여기가 주소검색 및 하얀 창
    var infoWindow = new naver.maps.InfoWindow({
      anchorSkew: true
    });

    map.setCursor('pointer');

    function searchCoordinateToAddress(latlng) {

      infoWindow.close();

      naver.maps.Service.reverseGeocode({
        coords: latlng,
        orders: [
          naver.maps.Service.OrderType.ADDR,
          naver.maps.Service.OrderType.ROAD_ADDR
        ].join(',')
      }, function(status, response) {
        if (status === naver.maps.Service.Status.ERROR) {
          if (!latlng) {
            return alert('ReverseGeocode Error, Please check latlng');
          }
          if (latlng.toString) {
            return alert('ReverseGeocode Error, latlng:' + latlng.toString());
          }
          if (latlng.x && latlng.y) {
            return alert('ReverseGeocode Error, x:' + latlng.x + ', y:' + latlng.y);
          }
          return alert('ReverseGeocode Error, Please check latlng');
        }

        var address = response.v2.address,
            htmlAddresses = [];

        if (address.jibunAddress !== '') {
            htmlAddresses.push('<div id="jibunAddress">[지번 주소] ' + address.jibunAddress + '</div>');
        }

        if (address.roadAddress !== '') {
            htmlAddresses.push('<div class="roadAddress" id="roadAddress">[도로명 주소] ' + address.roadAddress + '</div>');
        }

        infoWindow.setContent([
          '<div  data-x='+latlng.x+' data-y='+latlng.y+' style="padding:10px;min-width:200px;line-height:150%;">',
          '<h4 style="margin-top:5px;">검색 좌표</h4><br />',
          htmlAddresses.join('<br />'),
          '<br/>',
          '<button onclick="toStart(this)">출발지로</button>',
          '<button onclick="toEnd(this)">목적지로</button>',
          '<button onclick="toStopover(this)">경유지로</button>',
          '</div>'
        ].join('\n'));

        infoWindow.open(map, latlng);
      });
    }

    function searchAddressToCoordinate(address) {
      naver.maps.Service.geocode({
        query: address
      }, function(status, response) {
        if (status === naver.maps.Service.Status.ERROR) {
          if (!address) {
            return alert('Geocode Error, Please check address');
          }
          return alert('Geocode Error, address:' + address);
        }

        if (response.v2.meta.totalCount === 0) {
          return alert('No result.');
        }

        var htmlAddresses = [],
          item = response.v2.addresses[0],
          point = new naver.maps.Point(item.x, item.y);

        if (item.roadAddress) {
          htmlAddresses.push('<div class="roadAddress" id="roadAddress">[도로명 주소] ' + item.roadAddress + '</div>');
        }

        if (item.jibunAddress) {
          htmlAddresses.push('<div id="jibunAddress">[지번 주소] ' + item.jibunAddress + '</div>');
        }

        if (item.englishAddress) {
          htmlAddresses.push('[영문명 주소] ' + item.englishAddress);
        }

        infoWindow.setContent([
          '<div data-x='+item.x+' data-y='+item.y+' style="padding:10px;min-width:200px;line-height:150%;">',
          '<h4 style="margin-top:5px;">검색 주소 : '+ address +'</h4><br />',
          htmlAddresses.join('<br />'),
          '<br/>',
          '<button onclick="toStart(this)">출발지로</button>',
          '<button onclick="toEnd(this)">목적지로</button>',
          '<button onclick="toStopover(this)">경유지로</button>',
          '</div>'
        ].join('\n'));

        map.setCenter(point);
        infoWindow.open(map, point);
      });
    }

    function initGeocoder() {
      if (!map.isStyleMapReady) {
        return;
      }

      map.addListener('click', function(e) {
        searchCoordinateToAddress(e.coord);
      });

      $('#address').on('keydown', function(e) {
        var keyCode = e.which;

        if (keyCode === 13) { // Enter Key
          searchAddressToCoordinate($('#address').val());
        }
      });

      $('#submit').on('click', function(e) {
        e.preventDefault();

        searchAddressToCoordinate($('#address').val());
      });

       searchAddressToCoordinate('강남');
    }

    //초기 창
    naver.maps.onJSContentLoaded = initGeocoder;
    naver.maps.Event.once(map, 'init_stylemap', initGeocoder);

    </script>
    <%-- 자바스크립트 : 지도 관련 기능 불러오기.  --%>

    <br><br><br>

    <input type="text" id="addressText" name="addressText" placeholder="검색할 주소 입력">
    <button type="button" name="" onclick="search23()">검색하기</button>

    <br>

    <form id="excelImportForm" action="notUsethisAction" method="post" enctype="multipart/form-data">
      <input type="file" name="file0" accept="xlsx,xlsm,xlsb,xltx,xltxm,xlam,xls,xlt,csv">
    </form>
    <button type="button" name="button" onclick="excelImport()" disabled>엑셀 파일 받아오기</button> 현재 엑셀 파일 업로드가 되지 않습니다.
    <br>

    <table>
      <tr>
        <td>출발지:</td>
        <td id="startP"></td>
        <td id="startP2"></td>
        <td> <button id="startPosition" onclick="startPositionFunc()">삭제</button> </td>
      </tr>
      <tr>
        <td>목적지:</td>
        <td id="endP"></td>
        <td id="endP2"></td>
        <td> <button id="endPosition" onclick="endPositionFunc()">삭제</button> </td>
      </tr>
      <tr class="stopovers">
        <td>경유지:</td>
        <td class="stopover"></td>
        <td class="stopover2"></td>
        <td> <button onclick="stopoverPositionFunc(this)">삭제</button> </td>
      </tr>
    </table>
    경유지는 최대 10개까지 가능합니다. <br>
    <button type="button" name="button" onclick="finRes()">경로 계산!</button>
    <button type="button" name="button" onclick="exceller()">엑셀 파일로 export</button>
    <br>엑셀 파일은 바탕화면에 생성됩니다.

    <br><br><br>
      <div class="thePath">
        경로가 여기에 표시됨. <br><br>
        전체 경로 거리 (m):
        <span class="distance0"></span><br>
        전체 경로 예상 소요시간 (분) (## 배달을 제외한 단순 '거리시간'입니다. ):
        <span class="duration0"></span><br><br>
        네비게이션 :
        <div class="guide0">

        </div>
      </div>


<script type="text/javascript">

var markerStopovers=[];
  function search23(){
    // var search0 = $('#addressText').text();
    $('input#address').val($('#addressText').val());
    setTimeout(function(){$('#submit').click()}, 500);
  }


  function startPositionFunc(){
    $('#startP').text('');
    $('#startP2').text('');
    // markerStart =null;
  }
  function endPositionFunc(){
    $('#endP').text('');
    $('#endP2').text('');
  }
  function stopoverPositionFunc(r){
    var xy=$(r).parent('td').children('.stopover2').text();
    markerStopovers.splice(markerStopovers.indexOf(xy),1);
    $(r).parent('td').parent('tr.stopovers').remove();
  }

var ff = 0;

  function toStart(r){
    var di0 = $(r).parent();
    var x = di0.data('x');
    var y = di0.data('y');
    var position00 = di0.children().hasClass('roadAddress') ? di0.children('div#roadAddress').text() : di0.children('div#jibunAddress').text();

    $('#startP').text(position00);
    // $('#startP2').text(x+','+y+',name="출발지"');
    $('#startP2').text(x+','+y);

    // 마커 표시.
    var po000 = new naver.maps.LatLng(x, y);
    var markerStart = new naver.maps.Marker({
            position: po000,
            map: map,
            zIndex:15004,
    });
    ff=0;
    // markerStart.setMap(map);
    // markerStart.setMap();
  }

  function toEnd(r){
    var di0 = $(r).parent();
    var x = di0.data('x');
    var y = di0.data('y');
    var position00 = di0.children().hasClass('roadAddress') ? di0.children('div#roadAddress').text() : di0.children('div#jibunAddress').text();

    $('#endP').text(position00);
    // $('#endP2').text(x+','+y+',name="목적지"');
    $('#endP2').text(x+','+y);

    // 마커 표시.
    var markerEnd = new naver.maps.Marker({
            position: new naver.maps.LatLng(x, y),
            map: map,
            zIndex:15002,
    });
    ff=0;
    // markerEnd.setMap(map);
    markerEnd.setMap();
  }
  function toStopover(r){
    var di0 = $(r).parent();
    var x = di0.data('x');
    var y = di0.data('y');
    var position00 = di0.children().hasClass('roadAddress') ? di0.children('div#roadAddress').text() : di0.children('div#jibunAddress').text();


    $('.stopovers:last-child').children('.stopover').text(position00);
    $('.stopovers:last-child').children('.stopover2').text(x+','+y+',name="경유지"');
    // $('.stopovers:last-child').children('.stopover2').text(x+','+y);

    var app0 = '<tr class="stopovers"><td>경유지:</td><td class="stopover"></td><td class="stopover2"></td> <td> <button onclick="stopoverPositionFunc(this)">삭제</button> </td> </tr>';
    $('table').append(app0);

    // 마커 표시.
    var markerStopover = new naver.maps.Marker({
            position: new naver.maps.LatLng(x, y),
            map: map,
            zIndex:15001,
    });
    ff=0;
    // markerStopover.setMap(map);
    markerStopover.setMap();
    markerStopovers.push(markerStopover);
  }

  function finRes(){
    if($('#startP2').text() ==""){
      alert('출발지를 설정해주세요.');
      return;
    }
    if($('#endP2').text() ==""){
      alert('목적지를 설정해주세요.');
      return;
    }
    if($('.stopovers').eq(0).children('.stopover2').text() ==""){
      alert('경유지를 설정해주세요.');
      return;
    }
    if($('#startP2').text() == $('#endP2').text()){
      alert('출발지와 도착지가 같으면 이용할 수 없습니다. ');
      return;
    }
    ff = 1;

    //여기에
    findit();

  }

  function exceller(){

    if(ff){

      excelEX();
    }
    else{
      alert('경로 계산을 먼저 해주세요.');
    }

  }

  function findit(){
    var sp =     $('#startP2').text();
    var ep =     $('#endP2').text();
    // var sps = $('.stopover2').eq(0).text();
    // var sps = [];
    var s00 = $('.stopover2');
    var sps = s00.eq(0).text();

    for (var i = 1; i < s00.length; i++) {
      // sps.push(s00.eq(i).text());
      sps = sps + '|' + s00.eq(i).text();
    }
    //alert(sps);



    $.ajaxSetup({
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "POST",
          "Access-Control-Allow-Headers": "Origin, Methods, Content-Type",
       }
    });

    $.ajax({
      url : 'https://naveropenapi.apigw.ntruss.com/map-direction-15/v1/driving?X-NCP-APIGW-API-KEY-ID=thdo2oxpth&X-NCP-APIGW-API-KEY=rtDSiwlpDIPYOzfUxCQC6tr0WhOeVoI4itQ7oYOD',

      beforeSend: function(xhr) {
        xhr.setRequestHeader('Access-Control-Allow-Origin', '*');
        xhr.setRequestHeader('Access-Control-Allow-Methods', 'POST');
        xhr.setRequestHeader('Access-Control-Allow-Headers', 'Origin, Methods, Content-Type');
      },
      headers : {

        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Origin, Methods, Content-Type",
        "HTTPStatus": "OK",
      },
      data : {
        start:sp+',name="출발지"',
        goal:ep+',name="목적지"',
        waypoints:sps,
      },
      dataType : 'json',
      success : function(req){
        // var json0 = JSON.parse($(req));
        var json0 = $(req)[0];
        // var json0 = '$(req)';
        // json0 = JSON.parse(json0);
        alert( json0.message);
        // var distance0= $(req).data('route').data('trafast').data('summary').data('distance');
        var distance0= json0.route.traoptimal[0].summary.distance;
        var duration0= json0.route.traoptimal[0].summary.duration;
        duration0 = duration0 /1000;
        duration0 = duration0 /60;

        // var guide0 = JSON.stringify(json0.route.traoptimal[0].guide[0]);
        var guide0 = json0.route.traoptimal[0].guide;
        var gg0='';
        // $.each(guide0,function(key,value){
        //     gg0=gg0+
        // });
        for (var i = 0; i < guide0.length; i++) {
          if(guide0[i].instructions =='경유지'){
            gg0=gg0+'<br/><span class="checkpoints">'+guide0[i].instructions+'</span> , '+guide0[i].distance+'m';
          }
          else{
            gg0=gg0+'<br/>'+guide0[i].instructions+' , '+guide0[i].distance+'m';
          }
        }



        $('.distance0').text(distance0);
        $('.duration0').text(duration0);
        // $('.guide0').html(guide0);
        $('.guide0').html(gg0);



        // 경로선 표시
        // var pol0 = json0.route.traoptimal[0].path[0];
        var pol0 = json0.route.traoptimal[0].path;
        var polylinePath = [];
        // pol0.foreach(eachFunc);
        // pol0.foreach(function(item,index){
        //     polylinePath.push(new naver.maps.LatLng(item[0],item[1]));
        // });
//        for (var i = 0; i < pol0.length; i++) {
//          polylinePath.push(new naver.maps.LatLng(pol0[i][0],pol0[i][1]));
//        }
        // pol0.forEach((item, i) => {
        //     polylinePath.push(new naver.maps.LatLng(item[0],item[1]));
        //
        // });
        //
        // alert(pol0);
        var polyline = new naver.maps.Polyline({
            path: pol0,      //선 위치 변수배열
            strokeColor: '#FF0000', //선 색 빨강
            strokeOpacity: 0.7, //선 투명도 0 ~ 1
            strokeWeight: 5,   //선 두께
            zIndex: 15000,  //
            map: map           //오버레이할 지도
        });
        naver.maps.Event.addListener(polyline, "mouseover", function(e) {
            polyline.setOptions({
                strokeWeight: 20
            });
        });
        // polyline.setPath();

      //    map.data.addGeoJson($(req));  //흠......

        // var polyline = new naver.maps.Polyline({
        //     path: polylinePath,      //선 위치 변수배열
        //     strokeColor: '#FF0000', //선 색 빨강
        //     strokeOpacity: 0.7, //선 투명도 0 ~ 1
        //     strokeWeight: 5,   //선 두께
        //     map: new naver.maps.Map('map', {    zoom: 10   })           //오버레이할 지도
        // });
      },

    });

  }
  // function eachFunc(item,index){
  //
  // }

  function excelEX(){
    // $('#excelForm').children('input[name="starter"]').val($('#startP').text());
    // $('#excelForm').children('input[name="starter2"]').val($('#startP2').text());
    //   $('#excelForm').children('input[name="ender"]').val($('#endP').text());
    //   $('#excelForm').children('input[name="ender2"]').val($('#endP2').text());
    //
    //   var ways = $('.stopovers');
    //   for (var i = 0; i < ways.length - 1; i++) {
    //     $('#excelForm').children('input[name="waypoint"]').eq(i).val(ways[i].children('.stopover').text());
    //       $('#excelForm').children('input[name="waypoint2"]').eq(i).val(ways[i].children('.stopover2').text());
    //   }
    //
    //   $('#excelForm').children('distance0').val($('span.distance0').text());
    //   $('#excelForm').children('duration0').val($('span.duration0').text());
    //   $('#excelForm').submit();

    //

    // var data0 = [];
    // data0.push({'startPoint' : $('#startP').text()});
    // data0.push({'startPoint2' : $('#startP2').text()});
    // data0.push({'endPoint' : $('#endP').text()});
    // data0.push({'endPoint2' : $('#endP2').text()});
    //   var ways = $('.stopovers');
    // for (var i = 0; i < ways.length - 1; i++) {
    //   // data0.push((i + 1) + 'middle :' + ways[i].children('.stopover').text());
    //   // data0.push((i + 1) + 'middle2 :' + ways[i].children('.stopover2').text());
    //     data0.push({'middle' : ways.eq(i).children('.stopover').text()});
    //     data0.push({'middle2' : ways.eq(i).children('.stopover2').text()});
    // }
    // data0.push({'distance': $('span.distance0').text()}); //경로 거리
    // data0.push({'duration': $('span.duration0').text()}); //예상 시간

    // var data00 = JSON.stringify(data0);


    var data00 = {
      'startPoint' : $('#startP').text(),
      'startPoint2' : $('#startP2').text(),
      'endPoint' : $('#endP').text(),
      'endPoint2' : $('#endP2').text(),
      'distance': $('span.distance0').text(),
      'duration': $('span.duration0').text(),
    };

    var ways = $('.stopovers');
    for (var i = 0; i < ways.length - 1; i++) {
      $.extend(data00,{
          'middle' : ways.eq(i).children('.stopover').text(),
          'middle2' : ways.eq(i).children('.stopover2').text()
      });
    }

        // alert(data00);
        // alert(data00.startPoint);
    $.ajax({
      url : 'export.excel',
      type:'post',
      data : data00,
      dataType:'text',
      success:function(req){
        alert('엑셀 파일 만들기 성공');
      },
      fail:function(error){
        alert('엑셀 익스포트 실패');
      },
    });
  }


    function excelImport(){

      var form0 = $('#excelImportForm');
      var formData = new FormData(form0[0]);
      $.ajax({
        url : 'import.excel',
        type:'post',
        enctype: 'multipart/form-data',
        processData: false,
        contentType: false,
        data: formData,
        cache: false,
        timeout: 600000,
        success:function(req){
          alert(req);
        },
        error:function(error){
          alert('실패');
          console.log(error);
        }

      });

    }
</script>

<style media="screen">
  table{
    border:1px solid black;
  }
  td:nth-child(2){
    min-width: 360px;
    border:1px;
  }
  /* #map div{
    z-index: 10000;
    position: absolute;
  } */

  #startP2{
    display: none;
  }
  #endP2{
    display: none;

  }
  .stopover2{
    display: none;
  }


  .search #address{
    width: 150px;
    height: 20px;
    line-height: 20px;
    border: solid 1px #555;
    padding: 5px;
    font-size: 12px;
    box-sizing: content-box;
  }
  .search #submit{

    height: 30px;
    line-height: 30px;
    padding: 0 10px;
    font-size: 12px;
    border: solid 1px #555;
    border-radius: 3px;
    cursor: pointer;
    box-sizing: content-box;
  }
  .checkpoints{
    font-weight: 700;
  }
</style>
</body>
</html>
