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
        String filePath = "���"+System.currentTimeMillis()+".xlsx";    // ������ ���� ���
        //
        
        FileOutputStream fos = new FileOutputStream(filePath);
        
        XSSFWorkbook workbook = new XSSFWorkbook();
        XSSFSheet sheet = workbook.createSheet("ù��°��Ʈ");    // sheet ����
        
        XSSFRow curRow;
        
        
        curRow = sheet.createRow(0);
        curRow.createCell(0).setCellValue("����");
        curRow.createCell(1).setCellValue("����");
        curRow.createCell(2).setCellValue("GPS");
        curRow.createCell(5).setCellValue("��ü ��� �Ÿ�");
        curRow.createCell(6).setCellValue("���� �ҿ�ð�");
        
        curRow = sheet.createRow(1);
        curRow.createCell(0).setCellValue("�����");
        curRow.createCell(1).setCellValue(points.getStartPoint());
        curRow.createCell(2).setCellValue(points.getStartPoint2());
        curRow.createCell(5).setCellValue(points.getDistance());
        curRow.createCell(6).setCellValue(points.getDuration());
        
        curRow = sheet.createRow(2);
        curRow.createCell(0).setCellValue("������");
        curRow.createCell(1).setCellValue(points.getEndPoint());
        curRow.createCell(2).setCellValue(points.getEndPoint2());
        
        int row = points.getMiddle().get(0).split(" // ").length;    // ��� ũ��
        
        System.out.println(row);
        String [] stops = points.getMiddle().get(0).split(" // ");
        System.out.println(stops[row -1]);
        String [] stops2 = points.getMiddle2().get(0).split(" // ");
        System.out.println(stops2[0]);
        System.out.println(points.getMiddle().get(0));
        System.out.println(points.getMiddle2().get(0));
        for (int i = 1; i < row; i++) {
            curRow = sheet.createRow(i+2);    // row ����
            curRow.createCell(0).setCellValue("������"+(i));    // row�� �� cell ����
            curRow.createCell(1).setCellValue(stops[i]);
            curRow.createCell(2).setCellValue(stops2[i]);
        }
        
        workbook.write(fos);
        fos.close();
    }


	//��ó: https://swk3169.tistory.com/56 [swk�� ���������]
   
   
   public static Points getExcel(MultipartFile file) throws EncryptedDocumentException, IOException {
       Points points = new Points();

//       String filePath = "���.xlsx";
       String originFilename = file.getOriginalFilename();
       InputStream inputStream = new FileInputStream(originFilename);	//filepath

       // ���� �ε�
       Workbook workbook = WorkbookFactory.create(inputStream);
       // ��Ʈ �ε� 0, ù��° ��Ʈ �ε�
       Sheet sheet = workbook.getSheetAt(0);
       Iterator<Row> rowItr = sheet.iterator();
       // �ุŭ �ݺ�
       while (rowItr.hasNext()) {
           Row row = rowItr.next();
           // ù ��° ���� ����� ��� ��ŵ, 2��° ����� data �ε�
           if (row.getRowNum() == 0) {
               continue;
           }
           Iterator<Cell> cellItr = row.cellIterator();
           
           if(!cellItr.hasNext()) {
        	   System.out.println("�˸��� ���� ������ ����. ");
           }
           cellItr.next();	//1 0 
           Cell cell = cellItr.next(); // 1 1
           points.setStartPoint((String)getValueFromCell(cell));// ����� 	����
           cell = cellItr.next();	// 1 2
           points.setStartPoint2((String)getValueFromCell(cell)); //����� GPS
           cell = cellItr.next();	// 2 0
           cell = cellItr.next();	// 2 1
           points.setEndPoint((String)getValueFromCell(cell)); //������ ����
           cell = cellItr.next();	// 2 2
           points.setEndPoint2((String)getValueFromCell(cell)); //������ GPS
           
           
           List<String> middles = new ArrayList<String>();
           List<String> middles2 = new ArrayList<String>();
           // �� ���� �ѿ� �� �б� (�� �б�)
           while (cellItr.hasNext()) {
               Cell cell2 = cellItr.next();
               int index = cell2.getColumnIndex();
               switch (index) {
               case 0: // ������
                   break;
               case 1: // ����
                   middles.add(((String)getValueFromCell(cell2)));
                   break;
               case 2: // GPS��ǥ
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
