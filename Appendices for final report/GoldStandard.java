import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import java.io.BufferedReader;
public class GoldStandard {

	public GoldStandard() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) throws IOException{
		// TODO Auto-generated method stub
		
		File directory = new File("C:/Documents/GSLIS/590 Text Mining/Dataset/News");
		File[] listOfFiles = directory.listFiles();

        BufferedReader reader = null;
	    String line = "";
	    PrintWriter outputStream = null;
	    String outputFilename = "GoldStandard.csv";
	    String allText = "";
	    String instanceID = "";
	    String type = "";
	    String title = "";
	    boolean isearn = false;
	    boolean isacq = false;
	    
	    Pattern patID = Pattern.compile("\\<REUTERS.+NEWID=\"([0-9]+)\"\\>");
		Matcher matID;
		
		Pattern patType = Pattern.compile("\\<REUTERS.+LEWISSPLIT=\"([a-zA-Z]+)\"");
		Matcher matType;
		
		Pattern patTitle = Pattern.compile("\\<TITLE\\>(.+?)\\</TITLE\\>");
		Matcher matTitle;
		
		Pattern patBody = Pattern.compile(".+\\<BODY\\>([\\S\\s]+)");
		Matcher matBody;
		
	    try
	    {
	    	outputStream = new PrintWriter(outputFilename);
	    }
	    catch (FileNotFoundException e)
	    {
	    	System.out.println("Error creating the file.");
	    	System.exit(0);
	    }
	    
	    outputStream.println("InstanceID" + "," + "Type" + "," + "earn" + "," + "acq" + "," + "Title" + "," + "Body");
	    
		for (File file : listOfFiles)
		{
			if (file.isFile())
			{
				try
			    {
			    	reader =  new BufferedReader(new FileReader(file));
			    }
			    catch (FileNotFoundException e)
			    {
			    	System.out.println("Error opening the file " + file.getName());
			    	System.exit(0);
			    }

				while ((line = reader.readLine())!= null)
			    {
					if (line.startsWith("<REUTERS TOPICS=\"YES\""))
					{
						matType = patType.matcher(line);
						if (matType.find()) 
						{
							type = matType.group(1);
						}
						matID = patID.matcher(line);
						if (matID.find()) 
						{
							instanceID = matID.group(1);
						}
					
						while ((line = reader.readLine())!= null && !line.contains("</REUTERS>"))
						{
							if (line.startsWith("<TOPICS>"))
							{
								if (line.contains("earn"))
									isearn = true;
								if (line.contains("acq"))
									isacq = true;
							}
							if (line.startsWith("<TITLE>"))
							{
								matTitle = patTitle.matcher(line);
								if (matTitle.find()) 
								{
									title = matTitle.group(1);
									title = title.replaceAll(",", " ");
								}
							}
							if (line.contains("<BODY>"))
							{
								matBody = patBody.matcher(line);
								if (matBody.find()) 
								{
									allText = matBody.group(1) + " ";
								}
								while ((line = reader.readLine())!= null && !line.contains("</BODY>"))
								{
									allText = allText + " " + line;
									allText = allText.replaceAll(",", " ");
									allText = allText.replaceAll("[\\s]{2,}", " ");
								}
							}
						}
						
						if (isearn == true || isacq == true)
						{
							outputStream.println(instanceID + "," + type + "," + isearn + "," + isacq + "," + title + "," + allText);
						}
						allText = "";
						isearn = false;
						isacq = false;
					}
			    }
			}
		}

//				Properties props = new Properties();
//
//				props.setProperty("annotators","tokenize, ssplit, pos, lemma, ner, parse, dcoref, sentiment");
//
//				StanfordCoreNLP pipeline = new StanfordCoreNLP(props);
//				Annotation annotation = new Annotation(allText);
//				pipeline.annotate(annotation);
//				List<CoreMap> sentences = annotation.get(CoreAnnotations.SentencesAnnotation.class);
//			    int countSentence = 0;
//				for (CoreMap sentence : sentences) 
//				{
//					countSentence++;
//					outputStream.println(abstractID[countFile] + "|" + countSentence + "|" + sentence);
//				}
    
	    outputStream.flush();
		outputStream.close();

	}

}
