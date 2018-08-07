import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;


public class UpperBounds {
	static File amplFile;
	static File objFile;
	static int nodeCnt;
	static int sourceCnt;
	static int maxDeg;
	static Graph g;
	public static void main(String[] args) {
		amplFile = new File(args[0]);
		objFile = new File(args[1]);
		maxDeg = 0;
		nodeCnt = findParam("param n");
		sourceCnt = findParam("param s");

		g = new Graph();
		int ub = g.calcUpperBound();
		System.out.println("Upper boudn: " + ub);
		System.exit(ub);
	}

	private static void printResToFile(int lb, int dsb, int fb) {
      		try {

      		   // create a new writer
      		   PrintWriter pw = new PrintWriter(new FileWriter(objFile, true));
      		   // printf text with default locale.
      		   // %s indicates a string will be placed there, which is s
      		   pw.printf("%d\t%d\t%d\t", lb,fb, dsb);
      		   // flush the writer
      		   pw.flush();

      		} catch (Exception ex) {
      		   ex.printStackTrace();
      		}
	}

	
	private static int findParam(String paramStr) {
		int paramVal = 0;
		try (BufferedReader br = new BufferedReader(new FileReader(amplFile))) {
		    String line;
		    while ((line = br.readLine()) != null) {
		    	if (line.contains(paramStr)) {
		    		String[] words = line.split(" ");
		    		String lastWord = words[words.length - 1];
				//System.out.println(lastWord);
		    		String numStr = lastWord.substring(0, lastWord.length() - 1);
		    		paramVal = Integer.parseInt(numStr);
		    	}
		    }
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return paramVal;
	}
	
	public static class Node implements Comparable<Node> {
		int id;
		boolean isSource;
		ArrayList<Node> neighbours;
		public Node(int id, boolean isSource) {
			this.id = id;
			this.isSource = isSource;
			neighbours = new ArrayList<Node>();
		}
		
		public void addNeighbour(Node nb) {
			neighbours.add(nb);
		}

		public void setSource() {
			this.isSource = true;
		}
		
		public boolean isSource() {
			return isSource;
		}
		
		@Override
		public int compareTo(Node o) {
			int myNonSourceNeighbors = 0;
			int oNonSourceNeighbors = 0;
			for (Node n: neighbours) {
				if (n.isSource) {
					myNonSourceNeighbors ++;
				}
			}
			for (Node n: o.neighbours) {
				if (n.isSource) {
					oNonSourceNeighbors ++;
				}
			}
			if (myNonSourceNeighbors < oNonSourceNeighbors) return -1;
			if (myNonSourceNeighbors < oNonSourceNeighbors) return 1;
			return 0;
		}

		public Node getNeighbor() {
			for (Node nb: neighbours) {
				if (!nb.isSource) {
					return nb;
				}
			}
			return null;
		}
	}
	
	public static class Graph {
		ArrayList<Node> nodes;
		ArrayList<Node> sources;
		
		public Graph() {
			nodes = new ArrayList<Node>();
			sources = new ArrayList<Node>();
			for (int i = 0; i < nodeCnt; i++) {				
				Node n;
				if (i< sourceCnt) {					
					n = new Node(i, true);
					sources.add(n);
				}
				else {
					n = new Node(i, false);					
				}
				nodes.add(n);
				
			}
			String edgeStr = "";
			boolean reached = false;
			try (BufferedReader br = new BufferedReader(new FileReader(amplFile))) {
			    String line;
			    while ((line = br.readLine()) != null) {
			    	if (line.contains("set E")) {
			    		reached = true;
			    	}
			    	if (reached) {
			    		edgeStr += line + " ";
			    	}
			    }
				String[] individualEdgesStr = edgeStr.split(" ");
				for (String eStr: individualEdgesStr) {
					if (eStr.contains("(")) { // it is an edge string and not 'param' etc
						int u = Integer.parseInt(eStr.substring(eStr.indexOf('(') + 1, eStr.indexOf(',')));
						int v = Integer.parseInt(eStr.substring(eStr.indexOf(',') + 1, eStr.indexOf(')')));
						Node nodeU = nodes.get(u);
						Node nodeV = nodes.get(v);
						nodeU.addNeighbour(nodeV);
						nodeV.addNeighbour(nodeU);
					}
				}

			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		public int calcUpperBound() {
			int iter = 0;
			ArrayList<Node> toBecomeSources;
			while (sourceCnt < nodeCnt) {
				System.out.println("Iter: " + iter);
				iter ++;
				Collections.sort(sources);
				toBecomeSources = new ArrayList<Node>();
				for (Node n: sources) {
					System.out.println("Processing node: " + n.id);
					if (n.isSource) {
						Node nb = n.getNeighbor();
						if (nb != null) {
							System.out.println("Found neighbour: " + nb.id);
							nb.setSource();
							toBecomeSources.add(nb);
							sourceCnt++;
						}
					}
				}
				sources.addAll(toBecomeSources);
			}
			return iter;
		}
	}
	
}
