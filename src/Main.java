import java.io.IOException;

public class Main {

	public static void main(String[] args) throws IOException {
		Runner r = null;
		System.out.println("iter: " + args[0]);
		if (args.length == 1) { // ampl data file as an input
			r = new Runner(args[0]);
			r.run();
		} else if (args.length == 0) { // default file
			r = new Runner("data/disconnected.dat");
			r.run();
		} else if (args.length == 4) { // 4 args for generating a random graph
										// (# iteration, # nodes, # sources,
										// density of edges)
			int iter = Integer.parseInt(args[0]);
			int n = Integer.parseInt(args[1]);
			int s = Integer.parseInt(args[2]);
			float d = Float.parseFloat(args[3]);
			for (int i = 0; i < iter; i++) {
				Graph g = new Graph(n, s, d);
				String amplFileName = g.generateAMPL();
				r = new Runner(amplFileName);
				r.run();
			}
		} else {
			throw new IOException("Incorrect number of arguments ");
		}

	}
}
