
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
