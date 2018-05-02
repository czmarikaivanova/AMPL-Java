
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Random;


public class Graph {

	final int defaultK = 4;
	boolean[][] M;
	int s; // # of source sats
	int n;
	float delta;
	int id;
	Random rnd;
	/**
	 * Creates graph from an input file
	 * @param fName input file
	 */
	public Graph(String fName) {
			BufferedReader br = null;
			try {
				br = new BufferedReader(new FileReader(fName));
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			String line;
			try {
				while ((line = br.readLine()) != null) {
					if (line.startsWith("#", 0)) {
						id = Integer.parseInt(line.split(" ")[1]);
					}
					if (line.startsWith("param n")) {
						String laststr = line.split(" ")[3];
						laststr = laststr.substring(0, laststr.length() - 1);
						n = Integer.parseInt(laststr) + 1;
						M = new boolean[n][n];
					}
					if (line.startsWith("param m")) {
						String laststr = line.split(" ")[3];
						laststr = laststr.substring(0, laststr.length() - 1);
						s = Integer.parseInt(laststr);
					}
					if (line.startsWith("set E")) {
						String laststr = line.substring(9, line.length() - 1).trim();
						String[] edgeStrings = laststr.split(" ");
						for (String edgeStr: edgeStrings) {
							edgeStr = edgeStr.substring(1, edgeStr.length() - 1); // remove the parentheses
							int u = Integer.parseInt(edgeStr.split(",")[0]);
							int v = Integer.parseInt(edgeStr.split(",")[1]);
							M[u][v] = true;
							if (u != 0) {
								M[v][u] = true;
							}
						}
					}
				}
			} catch (NumberFormatException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} 
		}
		

	/**
	 * Generates random graph with n nodes including an artificial source zero that does not appear in the data file
	 * @param n # of nodes including root
	 * @param s # of source nodes
	 * @param delta density of edges
	 */
	public Graph(int n, int s, float delta) {
		rnd = new Random();
		id = rnd.nextInt(100000);
		this.s = s;
		this.n = n;
		this.delta = delta;
		M = new boolean[n][n];
		ArrayList<ArrayList<Integer>> sets = new ArrayList<ArrayList<Integer>>();
		ArrayList<Integer> firstSet = new ArrayList<Integer>();
		sets.add(firstSet);
		for (int i = 0; i < n; i ++) {  // init sets
			if (i <= s) {
				firstSet.add(i);
				if (i > 0) {
					M[0][i] = true;
				}
			}
			else {
				ArrayList<Integer> set =  new ArrayList<Integer>();
				set.add(i);
				sets.add(set);
			}
		}
		while (sets.size() > 1) {
			int u = rnd.nextInt(n-1) + 1;
			int v = rnd.nextInt(n-1) + 1;
			ArrayList<Integer> Lu = findSet(sets, u);
			ArrayList<Integer> Lv = findSet(sets, v);
			if (Lu != Lv) {
				merge(sets,Lu,Lv);
				M[u][v] = true;
				M[v][u] = true;
			}
		}
		// add remaining edges according to given density delta
		for (int i = 1; i < n; i++) {
			for (int j = i+1; j < n; j++) {
				if (!M[i][j]) {
					float rndF = rnd.nextFloat();
					if (rndF < delta) {
						M[i][j] = true;
						M[j][i] = true;
					}
				}
				
			}
		}
	}

	public int getN() {
		return n;
	}
	
	public int getS() {
		return s;
	}
	
	// Kruskal merge
	private void merge(ArrayList<ArrayList<Integer>> sets,ArrayList<Integer> lu, ArrayList<Integer> lv) {
		sets.remove(lu);
		sets.remove(lv);
		lu.addAll(lv);
		sets.add(lu);
	}

	// Find which component a vertex u belongs to
	private ArrayList<Integer> findSet(ArrayList<ArrayList<Integer>> sets, int u) {
		for (ArrayList<Integer> set: sets) {
			if (set.contains(u)) {
				return set;
			}
		}
		return null;
	}

	public String toString() {
		String str = "   ";
		for (int i = 0; i < M.length; i++) {
			str += i + " ";
		}
		for (int i = 0; i < M.length; i++) {
			str += "\n" + i + "  ";
			for (int j = 0; j < M[i].length; j++) {
				if (M[i][j]) {
					str += "1 ";
				}
				else {
					str += "0 ";
				}
			}
		}
		return str;
	}
	
	public String generateAMPL() {
        try  {
        	int fileNumber = new File("data/").list().length + 1;
        	String dataFileStr = "data/ampl" + fileNumber  + ".dat";
        	File datafile = new File(dataFileStr);
            System.out.println("Saving: AMPL input");
            FileWriter fw = new FileWriter(datafile,false); //the true will append the new data
            fw.write("# " + id + "\n");
            int nodeCnt = n-1; // number of nodes without the artificial source 0;
            fw.write("param k := " + defaultK + ";\n");
            fw.write("param n := " + nodeCnt + ";\n");
            fw.write("param s := " + s + ";\n");
            fw.write("set E := ");
            for (int i = 1; i < n; i ++) {
            	for (int j = i + 1; j < n; j++) {
            		if (M[i][j]) {
            			fw.write(" (" + i + "," + j + ")");
            		}
            	}
            }
            fw.write(";");
            fw.close();
            return dataFileStr;
        }
        catch(IOException ioe) {
            System.err.println("IOException: " + ioe.getMessage());
            return null;
        } 
	}


	public boolean isAdjacent(int i, int j) {
		return M[i][j];
	}
	
}
