import csv
import io
import os
import xml.etree.ElementTree


class MapData:
    def __init__(self):
        self.rows: int = 0
        self.cols: int = 0
        self.tiles: list[list[int]] = []

    def read_tmx(self, source: os.PathLike | io.IOBase) -> None:
        tree = xml.etree.ElementTree.parse(source)
        root = tree.getroot()
        level = root.find("./layer/data")

        if level is None:
            raise KeyError("Missing level data")

        if level.attrib.get("encoding") != "csv":
            raise ValueError("level should be saved in CSV format")

        self.tiles = []
        self.rows = 0
        self.cols = 0

        for row in csv.reader(io.StringIO(level.text)):
            row = [*filter(bool, row)]
            if not row:
                continue
            if self.cols == 0:
                self.cols = len(row)
            elif self.cols != len(row):
                raise ValueError("level data should be rectangular")
            self.rows += 1
            self.tiles.append([max(int(cell) - 1, 0) for cell in row])

    def write_level(self, output: io.IOBase) -> None:
        output.write(self.rows.to_bytes(1, signed=False))
        output.write(self.cols.to_bytes(1, signed=False))
        for row in self.tiles:
            for cell in row:
                output.write(cell.to_bytes(1, signed=False))

    def write_blockset(self, output: io.IOBase) -> None:
        assert self.rows % 2 == 0
        assert self.cols % 2 == 0
        for y in range(0, self.rows, 2):
            for x in range(0, self.rows, 2):
                tiles = [
                    self.tiles[y + 0][x + 0],
                    self.tiles[y + 0][x + 1],
                    self.tiles[y + 1][x + 0],
                    self.tiles[y + 1][x + 1],
                ]
                for cell in tiles:
                    output.write(cell.to_bytes(1, signed=False))
