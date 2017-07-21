import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.conf.Configuration;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class SentimentAnalysis {

    public static class SentimentSplit extends Mapper<Object, Text, Text, IntWritable> {
        public Map<String, String> emotionLibrary = new HashMap<String, String>();

        @Override
        protected void setup(Context context) throws IOException, InterruptedException {
            super.setup(context);
            // read in (word, sentiment) pair
             Configuration configuration = context.getConfiguration();
            String path = configuration.get("dictionary", "");

            BufferedReader br = new BufferedReader(new FileReader(path));
            String line = br.readLine();

            while (line != null) {
                String[] word_emotion = line.toLowerCase().split("\\s+");
                emotionLibrary.put(word_emotion[0], word_emotion[1]);
                line = br.readLine();
            }
            br.close();
        }

        @Override
        protected void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            super.map(key, value, context);
            String[] words = value.toString().trim().split("\\s+");
            for (String word : words) {
                if (emotionLibrary.containsKey(word.toLowerCase()))
                    context.write(new Text(emotionLibrary.get(word.toLowerCase())), new IntWritable(1));
            }
        }
    }

    public static class SentimentCollect extends Reducer<Text, IntWritable, Text, IntWritable> {
        @Override
        protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
            super.reduce(key, values, context);
            int sum = 0;
            for (IntWritable v : values) {
                sum += v.get();
            }
            context.write(key, new IntWritable(sum));
        }
    }

    public static void main(String[] args) throws Exception
    {
        // context used for communication
        // configuration used for system's configuration, read from command line
        Configuration configuration = new Configuration();
        configuration.set("dictionary", args[2]);

        Job job = Job.getInstance(configuration);
        job.setJarByClass(SentimentAnalysis.class);
        job.setMapperClass(SentimentSplit.class);
        job.setReducerClass(SentimentCollect.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        job.waitForCompletion(true);

    }
}