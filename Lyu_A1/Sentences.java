import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import edu.stanford.nlp.ling.CoreAnnotations;
import edu.stanford.nlp.pipeline.Annotation;
import edu.stanford.nlp.pipeline.StanfordCoreNLP;
import edu.stanford.nlp.util.CoreMap;

import java.io.BufferedReader;


public class Sentences {

	public Sentences() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) throws IOException{
		// TODO Auto-generated method stub

		File directory = new File("C:/Documents/GSLIS/590 Text Mining/Assignment 1/Part1/awards_1990/awd_1990_00");
		File[] listOfFiles = directory.listFiles();

        BufferedReader reader = null;
	    String line = "";
	    PrintWriter outputStream = null;
	    String outputFilename = "Sentences.txt";
	    int countFile = 0;
	    String[] abstractID = new String[3];
	    String allText = "";	    
	    
	    Pattern patID = Pattern.compile("File.+: a([0-9]+)"); //includes null
		Matcher matID;
		
	    try
	    {
	    	outputStream = new PrintWriter(outputFilename);
	    }
	    catch (FileNotFoundException e)
	    {
	    	System.out.println("Error creating the file.");
	    	System.exit(0);
	    }
	    
		for (File file : listOfFiles)
		{
			if (file.isFile() && countFile < 3)
			{
				allText = "";
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
				    matID = patID.matcher(line) ;
					if (matID.find()) 
					{
						abstractID[countFile] = matID.group(1);
					}
					if (line.startsWith("Abstract")) 
					{
						while ((line = reader.readLine())!= null)
						{
							allText = allText + line;
							allText = allText.replaceAll("[\\s]{2,}", " ");
						}
					}	
				
			    }

				Properties props = new Properties();

				props.setProperty("annotators","tokenize, ssplit");

				StanfordCoreNLP pipeline = new StanfordCoreNLP(props);
				Annotation annotation = new Annotation(allText);
				pipeline.annotate(annotation);
				List<CoreMap> sentences = annotation.get(CoreAnnotations.SentencesAnnotation.class);
			    int countSentence = 0;
				for (CoreMap sentence : sentences) 
				{
					countSentence++;
					outputStream.println(abstractID[countFile] + "|" + countSentence + "|" + sentence);
				}

				outputStream.println("Abstract " + abstractID[countFile] + " has " + countSentence + " sentences.");
				outputStream.println();
				countFile++;
			}
		}
    
	    outputStream.flush();
		outputStream.close();
		
	}

}
