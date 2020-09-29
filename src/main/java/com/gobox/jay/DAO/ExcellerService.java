package com.gobox.jay.DAO;

import java.io.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.poi.EncryptedDocumentException;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.web.multipart.MultipartFile;

import com.gobox.jay.DTO.Points;

public class ExcellerService {
   public static void writeExcelFile(Points points) throws EncryptedDocumentException, IOException {
        String filePath = "경로"+System.currentTimeMillis()+".xlsx";    // 저장할 파일 경로
        //
        
        FileOutputStream fos = new FileOutputStream(filePath);
        
        XSSFWorkbook workbook = new XSSFWorkbook();
        XSSFSheet sheet = workbook.createSheet("첫번째시트");    // sheet 생성
        
        XSSFRow curRow;
        
        
        curRow = sheet.createRow(0);
        curRow.createCell(0).setCellValue("종류");
        curRow.createCell(1).setCellValue("지역");
        curRow.createCell(2).setCellValue("GPS");
        curRow.createCell(5).setCellValue("전체 경로 거리");
        curRow.createCell(6).setCellValue("예상 소요시간");
        
        curRow = sheet.createRow(1);
        curRow.createCell(0).setCellValue("출발지");
        curRow.createCell(1).setCellValue(points.getStartPoint());
        curRow.createCell(2).setCellValue(points.getStartPoint2());
        curRow.createCell(5).setCellValue(points.getDistance());
        curRow.createCell(6).setCellValue(points.getDuration());
        
        curRow = sheet.createRow(2);
        curRow.createCell(0).setCellValue("목적지");
        curRow.createCell(1).setCellValue(points.getEndPoint());
        curRow.createCell(2).setCellValue(points.getEndPoint2());
        
        int row = points.getMiddle().get(0).split(" // ").length;    // 경로 크기
        
        System.out.println(row);
        String [] stops = points.getMiddle().get(0).split(" // ");
        System.out.println(stops[row -1]);
        String [] stops2 = points.getMiddle2().get(0).split(" // ");
        System.out.println(stops2[0]);
        System.out.println(points.getMiddle().get(0));
        System.out.println(points.getMiddle2().get(0));
        for (int i = 1; i < row; i++) {
            curRow = sheet.createRow(i+2);    // row 생성
            curRow.createCell(0).setCellValue("경유지"+(i));    // row에 각 cell 저장
            curRow.createCell(1).setCellValue(stops[i]);
            curRow.createCell(2).setCellValue(stops2[i]);
        }
        
        workbook.write(fos);
        fos.close();
    }


	//출처: https://swk3169.tistory.com/56 [swk의 지식저장소]
   
   
   public static Points getExcel(MultipartFile file) throws EncryptedDocumentException, IOException {
       Points points = new Points();

//       String filePath = "경로.xlsx";
       String originFilename = file.getOriginalFilename();
       InputStream inputStream = new FileInputStream(originFilename);	//filepath

       // 엑셀 로드
       Workbook workbook = WorkbookFactory.create(inputStream);
       // 시트 로드 0, 첫번째 시트 로드
       Sheet sheet = workbook.getSheetAt(0);
       Iterator<Row> rowItr = sheet.iterator();
       // 행만큼 반복
       while (rowItr.hasNext()) {
           Row row = rowItr.next();
           // 첫 번째 행이 헤더인 경우 스킵, 2번째 행부터 data 로드
           if (row.getRowNum() == 0) {
               continue;
           }
           Iterator<Cell> cellItr = row.cellIterator();
           
           if(!cellItr.hasNext()) {
        	   System.out.println("알맞지 않은 형식의 파일. ");
           }
           cellItr.next();	//1 0 
           Cell cell = cellItr.next(); // 1 1
           points.setStartPoint((String)getValueFromCell(cell));// 출발지 	지역
           cell = cellItr.next();	// 1 2
           points.setStartPoint2((String)getValueFromCell(cell)); //출발지 GPS
           cell = cellItr.next();	// 2 0
           cell = cellItr.next();	// 2 1
           points.setEndPoint((String)getValueFromCell(cell)); //목적지 지역
           cell = cellItr.next();	// 2 2
           points.setEndPoint2((String)getValueFromCell(cell)); //목적지 GPS
           
           
           List<String> middles = new ArrayList<String>();
           List<String> middles2 = new ArrayList<String>();
           // 한 행이 한열 씩 읽기 (셀 읽기)
           while (cellItr.hasNext()) {
               Cell cell2 = cellItr.next();
               int index = cell2.getColumnIndex();
               switch (index) {
               case 0: // 경유지
                   break;
               case 1: // 지역
                   middles.add(((String)getValueFromCell(cell2)));
                   break;
               case 2: // GPS좌표
                   middles2.add(((String)getValueFromCell(cell2)));
                   break;
               }
           }
           points.setMiddle(middles);
           points.setMiddle2(middles2);
       }
       return points;
   }

   private static Object getValueFromCell(Cell cell) {
       switch (cell.getCellType()) {
       case STRING:
           return cell.getStringCellValue();
       case BOOLEAN:
           return cell.getBooleanCellValue();
       case NUMERIC:
           if (DateUtil.isCellDateFormatted(cell)) {
               return cell.getDateCellValue();
           }
           return cell.getNumericCellValue();
       case FORMULA:
           return cell.getCellFormula();
       case BLANK:
           return "";
       default:
           return "";
       }
   }

}
