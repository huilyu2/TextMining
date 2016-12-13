import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Properties;
import java.util.TreeMap;

import edu.stanford.nlp.ling.CoreAnnotations;
import edu.stanford.nlp.pipeline.Annotation;
import edu.stanford.nlp.pipeline.StanfordCoreNLP;
import edu.stanford.nlp.util.CoreMap;
import java.io.BufferedReader;

public class Distribution {

	public Distribution() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) throws IOException{
		// TODO Auto-generated method stub

		File directory = new File("C:/Documents/GSLIS/590 Text Mining/Assignment 1/Abstracts/");
		File[] listOfFiles = directory.listFiles();

        BufferedReader reader = null;
	    String line = "";
	    PrintWriter outputStream = null;
	    //String outputFilename = "Distribution.txt";
	    String outputFilename = "Distribution.csv";
	    String allText = "";	    
	    TreeMap<Integer, Integer> distributionMap = new TreeMap<Integer, Integer>();
		
	    try
	    {
	    	outputStream = new PrintWriter(outputFilename);
	    }
	    catch (FileNotFoundException e)
	    {
	    	System.out.println("Error creating the file.");
	    	System.exit(0);
	    }
	    
	    outputStream.println("Number of sentences" + "," + "Number of abstracts");
	    
		for (File file : listOfFiles)
		{
			if (file.isFile())
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
				}

				if (!distributionMap.containsKey(countSentence))
		        {
					distributionMap.put(countSentence, 1);
		        }
		        else
		        {			        		
		        	int number = distributionMap.get(countSentence);
		        	number++;
		        	distributionMap.put(countSentence, number);
		        } 
			}
		}
		
		for (Integer Sentence : distributionMap.keySet())
		{
			Integer Abstract = distributionMap.get(Sentence);
			outputStream.println(Sentence + "," + Abstract);
		}

	    outputStream.flush();
		outputStream.close();
		
	}

}
