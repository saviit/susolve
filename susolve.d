import std.stdio;
import std.string;
import std.format;
import std.conv;
import std.algorithm;
import std.range;

/**
 * Simple solver for 3x3x3 (or 9x9) sudoku puzzles.
 * Copyright 2019 Sami Viitanen, github.com/saviit
 * */



/**
 * Represents a single numeric cell on the sudoku puzzle board
 *
 * Params:
 *  value = number that is on the board (1-9)
 *  alt_values = values that the cell could have
 * */
struct Cell {
    /// holds the cell's current value
    int value;
    /// holds possible values for the cell
    int[] alt_values;
    /// holds information whether or not the cell's value has been determined
    bool hasValue;
    /// holds information of what block the cell belongs to
    string parentBlock;

    
    string toString() const {
        string str;
        if (0 < this.value && this.value < 10) {
            str = format("%d", this.value);
        } else str = "-";
        return str;
    }
}

/// Represents a 3-dimensional vector, or a triple
struct Vec3 {
    /// components
    int a, b ,c;
    
    ///constructor
    this(int a, int b, int c) {
        this.a = a;
        this.b = b;
        this.c = c;
    }
}

/// Returns: index of the first occurrence of an integer in the specified array, or -1 if the integer was not found
int indexOf(int[] arr, int a) {
    int i = 0;
    while (i < arr.length) {
        if (arr[i] == a) return i;
        else continue;
    }
    return -1;
}

void main()
{
    Cell[9][9] cells;
    string[][] pBlock = [["A", "A", "A", "B", "B", "B", "C", "C", "C"], 
                         ["A", "A", "A", "B", "B", "B", "C", "C", "C"], 
                         ["A", "A", "A", "B", "B", "B", "C", "C", "C"], 
                         ["D", "D", "D", "E", "E", "E", "F", "F", "F"], 
                         ["D", "D", "D", "E", "E", "E", "F", "F", "F"], 
                         ["D", "D", "D", "E", "E", "E", "F", "F", "F"], 
                         ["G", "G", "G", "H", "H", "H", "I", "I", "I"],
                         ["G", "G", "G", "H", "H", "H", "I", "I", "I"],
                         ["G", "G", "G", "H", "H", "H", "I", "I", "I"]];

    // below: corner case, gets stuck because of mirrored value candidates
    // Vec3[] start = [Vec3(0, 1, 8), Vec3(0, 4, 4), Vec3(0, 7, 9), Vec3(0, 8, 6), 
    //                 Vec3(1, 2, 4), Vec3(1, 4, 6), Vec3(1, 5, 9), Vec3(1, 7, 2), 
    //                 Vec3(2, 0, 6), Vec3(2, 1, 7), Vec3(2, 3, 2), Vec3(2, 4, 5),
    //                 Vec3(3, 2, 8), Vec3(3, 3, 5), Vec3(3, 4, 7), 
    //                 Vec3(4, 0, 9), Vec3(4, 2, 3),
    //                 Vec3(5, 3, 1), Vec3(5, 4, 9), Vec3(5, 5, 2), Vec3(5, 6, 4), Vec3(5, 7, 3), 
    //                 Vec3(6, 2, 1), Vec3(6, 5, 4), Vec3(6, 6, 3),
    //                 Vec3(7, 1, 4), Vec3(7, 3, 8),
    //                 Vec3(8, 0, 2), Vec3(8, 1, 3), Vec3(8, 2, 7)];

    
    Vec3[] start = [Vec3(0, 3, 9), Vec3(0, 5, 1), Vec3(0, 7, 2), Vec3(0, 8, 6), 
                    Vec3(1, 3, 6), Vec3(1, 7, 3), Vec3(1, 8, 4),
                    Vec3(2, 0, 2), Vec3(2, 1, 8), Vec3(2, 4, 3), Vec3(2, 6, 5), Vec3(2, 7, 1),
                    Vec3(3, 1, 2), Vec3(3, 4, 4), Vec3(3, 7, 8), 
                    Vec3(4, 1, 3), Vec3(4, 2, 8), Vec3(4, 4, 1), Vec3(4, 5, 6),
                    Vec3(5, 0, 6), Vec3(5, 5, 3), Vec3(5, 7, 5), 
                    Vec3(6, 0, 8), Vec3(6, 7, 4), Vec3(6, 8, 5),
                    Vec3(7, 6, 9), Vec3(7, 8, 8),
                    Vec3(8, 0, 3), Vec3(8, 1, 4), Vec3(8, 4, 8), Vec3(8, 5, 5), Vec3(8, 7, 6), Vec3(8, 8, 2)];

    // initialize board
    for (int i = 0; i < cells.length; i++) {
        for (int j = 0; j < cells[i].length; j++) {
            cells[i][j].value = -1;
            cells[i][j].alt_values = [1, 2, 3, 4, 5, 6, 7, 8, 9];
            cells[i][j].hasValue = false;
            cells[i][j].parentBlock = pBlock[i][j];
        }
    }
    
    // populate with pre-determined values
    foreach (ref Vec3 v; start) {
        cells[v.a][v.b].value = v.c;
        cells[v.a][v.b].hasValue = true;
        cells[v.a][v.b].alt_values.length = 0;
    }

    bool reqResolve = true;
    while (reqResolve) {
        resolveAltValues(cells, reqResolve);
        for (int j = 0; j < cells.length; j++) {
            for (int k = 0; k < cells[j].length; k++) {
                if (cells[j][k].hasValue) { continue; }
                else {

                    int vcount = 0;
                    int fIndex = 0;
                    // for (int i = 0; i < cells[j][k].alt_values.length; i++) {
                    //     if (cells[j][k].alt_values[i] != 0 && cells[j][k].alt_values[i] > 0) { vcount++; fIndex = i; }
                    // }
                    vcount = to!int(cells[j][k].alt_values.length);
                    
                    if (vcount == 1) {
                        reqResolve = true;
                        cells[j][k].value = cells[j][k].alt_values[fIndex];
                        cells[j][k].hasValue = true;
                        cells[j][k].alt_values.length = 0;
                    } 
                }
            }
        }
    }

    printBoard(cells);

}

/// resolve possible values for cells
void resolveAltValues(ref Cell[9][9] cells, ref bool reqResolve) {
    // resolve possible values for cells
    for (int i = 0; i < cells.length; i++) {
        // gather existing values for row
        int[] row_det_cells = new int[9];
        foreach (Cell c; cells[i]) {
            if (c.hasValue) { row_det_cells ~= c.value; }
            else continue;
        }
        for (int j = 0; j < cells[i].length; j++) {
            // gather existing values for column
            int[] col_det_cells = new int[9];
            for (int k = 0; k < cells.length; k++) {
                if (cells[k][j].hasValue) { col_det_cells ~= cells[k][j].value; }
                else continue;
            }
            // gather existing values for 3x3 block of cells
            int[] block_det_cells = new int[9];
            int minx, miny, maxx, maxy;
            const int cells_len = to!int(cells.length);
            minx = ((j - 2) >= 0) ? j - 2 : 0;
            miny = ((i - 2) >= 0) ? i - 2 : 0;
            maxx = ((j + 2) < cells[i].length) ? j + 2 : cells_len - 1; 
            maxy = ((i + 2) < cells.length) ? i + 2 : cells_len - 1;
            for (int y = miny; y <= maxy; y++) {
                for (int x = minx; x <= maxx; x++) {
                    if (cells[y][x].parentBlock == cells[i][j].parentBlock) {
                        if (cells[y][x].hasValue) { block_det_cells ~= cells[y][x].value;}
                    }
                }
            }
            // sort and combine existing values
            row_det_cells.sort();
            col_det_cells.sort();
            block_det_cells.sort();
            int[][] rcb_det_cells = [row_det_cells, col_det_cells, block_det_cells];
            auto det_cells = multiwayUnion(rcb_det_cells);
            // possible values for the cell are the complement
            auto diff = setDifference(cells[i][j].alt_values, det_cells);
            cells[i][j].alt_values = array(diff);
            
        }
    }
    reqResolve = false;
}

/// print the cell values
void printBoard(Cell[9][9] cells) {

    int aval_len = 0;
    int cells_len = 0;
    for (int i = 0; i < cells.length; i++) {
        for (int j = 0; j < cells[i].length; j++) {
            string aval_str = format("%s", cells[i][j].alt_values);
            if (aval_str.length > aval_len) {
                try {
                    aval_len = to!int(aval_str.length);
                } catch (ConvOverflowException) {
                    writeln("Could not convert alt_values length to int.");
                }
            }
        }
    }
    try {
        cells_len = to!int(cells.length);
    } catch (ConvOverflowException) {
        writeln("Could not convert cells length to int.");
    }

    for (int i = 0; i < cells.length; i++) {
        
        int k = 0;
        while (k < (aval_len * cells_len + cells_len)) {
            if ((k % (aval_len + 1)) == 0) { writef("|"); }
            else writef("-");
            k++;
        }
        writef("|\n");

        writef("|");
        for (int j = 0; j < cells[i].length; j++) {
            // string aval_str = format("%s", cells[i][j].alt_values);
            writef(center(format("%s", cells[i][j]), aval_len, ' '));
            writef("|");
        }
        writef("\n|");
        for (int j = 0; j < cells[i].length; j++) {
            string aval_str;
            if (cells[i][j].alt_values.length != 0) {
                aval_str = format("%s", cells[i][j].alt_values);
            } else aval_str = "";
            writef(center(aval_str, aval_len, ' '));
            // writef(center(cells[i][j].parentBlock, aval_len, ' ')); //DEBUG
            writef("|");
        }
        writef("\n");
        k = 0;
        while (k < (aval_len * cells_len + cells_len)) {
            if ((k % (aval_len + 1)) == 0) { writef("|"); }
            else writef("_");
            k++;
        }
        writef("|\n");
        
    }
}
