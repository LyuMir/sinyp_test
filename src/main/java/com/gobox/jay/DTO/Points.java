package com.gobox.jay.DTO;

import java.util.List;

public class Points {

	private String startPoint;
	private String startPoint2 ;
	private String endPoint;
	private String endPoint2;
	private String distance;
	private String duration;
	
	private List<String> middle;
	private List<String> middle2;
	
	
	public String getStartPoint() {
		return startPoint;
	}
	public void setStartPoint(String startPoint) {
		this.startPoint = startPoint;
	}
	public String getStartPoint2() {
		return startPoint2;
	}
	public void setStartPoint2(String startPoint2) {
		this.startPoint2 = startPoint2;
	}
	public String getEndPoint() {
		return endPoint;
	}
	public void setEndPoint(String endPoint) {
		this.endPoint = endPoint;
	}
	public String getEndPoint2() {
		return endPoint2;
	}
	public void setEndPoint2(String endPoint2) {
		this.endPoint2 = endPoint2;
	}
	public String getDistance() {
		return distance;
	}
	public void setDistance(String distance) {
		this.distance = distance;
	}
	public String getDuration() {
		return duration;
	}
	public void setDuration(String duration) {
		this.duration = duration;
	}
	public List<String> getMiddle() {
		return middle;
	}
	public void setMiddle(List<String> middle) {
		this.middle = middle;
	}
	public List<String> getMiddle2() {
		return middle2;
	}
	public void setMiddle2(List<String> middle2) {
		this.middle2 = middle2;
	}
	
	
	
	
}