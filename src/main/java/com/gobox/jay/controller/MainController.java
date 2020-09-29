package com.gobox.jay.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

import org.apache.poi.EncryptedDocumentException;
import org.springframework.stereotype.Component;
//import org.springframework.http.HttpHeaders;
//import org.springframework.http.HttpStatus;
//import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.gobox.jay.DAO.ExcellerService;
import com.gobox.jay.DTO.Points;



@Controller
public class MainController {

	@RequestMapping("/index")
	public String mainer() {
		return "/WEB-INF/views/index.jsp";
	}	

	@RequestMapping("/main.order")
	public String order_main() {
		
		return "/WEB-INF/views/order/main.jsp";
	}
	@RequestMapping("/main.deliver")
	public String deliver_main() {

//		HttpHeaders header = new HttpHeaders();
//		header.add("Access-Control-Allow-Origin", "*");
//		header.add("Access-Control-Allow-Methods", "POST");
//		header.add("Access-Control-Allow-Headers", "Origin, Methods, Content-Type");
		
//		return new ResponseEntity<>("/WEB-INF/views/deliver/main.jsp",header,HttpStatus.OK);
		return "/WEB-INF/views/deliver/main.jsp";
	}
	
//	@RequestMapping("/main2.deliver")
//	public ResponseEntity<String> ex148(){
//		
//		String msg = "okok";
//		
//		HttpHeaders header = new HttpHeaders();
//		header.add("", "");
//		
//		return new ResponseEntity<>(msg,header,HttpStatus.OK);
//	}
	
	@ResponseBody
	@RequestMapping("/export.excel")
	public String exceller(@RequestParam MultiValueMap<String, String> params) {
		
		
		String startPoint = params.get("startPoint").get(0);
		String startPoint2 = params.get("startPoint2").get(0);
		String endPoint = params.get("endPoint").get(0);
		String endPoint2 = params.get("endPoint2").get(0);
		String distance = params.get("distance").get(0);
		String duration = params.get("duration").get(0);
		
		List<String> middle = params.get("middle");
		List<String> middle2 = params.get("middle2");

		Points points = new Points();
		points.setStartPoint(startPoint);
		points.setStartPoint2(startPoint2);
		points.setEndPoint(endPoint);
		points.setEndPoint2(endPoint2);
		points.setDistance(distance);
		points.setDuration(duration);
		points.setMiddle(middle);
		points.setMiddle2(middle2);
		
		try {
			ExcellerService.writeExcelFile(points);	//엑셀로 익스포트
		} catch (EncryptedDocumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return "성공";
	}
	

	@ResponseBody
	@RequestMapping(value="/import.excel", method=RequestMethod.POST)
	public String import0(@RequestParam(name="file0") MultipartFile file) {
		Points points = null;
		try {	
			points = new ExcellerService().getExcel(file);
		} catch (EncryptedDocumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String rr = "";
		if(points ==null) rr = "실패!";
		else rr = "sth";
		
		return rr;
	}
	
	
	@RequestMapping("/sth2")
	public String sth2(@RequestParam String k) {
		return "/WEB-INF/views/sth2.jsp"; //이런 식이 됩니다. 
	}
	
	
	
}


