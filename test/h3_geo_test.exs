defmodule H3GeoTest do
  use ExUnit.Case

  describe "point_to_cell/2" do
    test "it returns the correct cell" do
      point = %Geo.Point{coordinates: {-1.0, 51.0}, srid: 4326}

      assert {:ok, 0x86195985FFFFFFF} == H3Geo.point_to_cell(point, 6)
    end
  end

  describe "polygon_to_cells/2" do
    test "it returns the correct cells" do
      polygon =
        File.read!(Path.join(__DIR__, "support/polygon.geojson"))
        |> Jason.decode!()
        |> Geo.JSON.decode!()

      assert {:ok,
              [
                0x86195DADFFFFFFF,
                0x86195D377FFFFFF,
                0x86195D367FFFFFF,
                0x86195DACFFFFFFF,
                0x86195D347FFFFFF,
                0x86195D36FFFFFFF,
                0x86194AD97FFFFFF,
                0x86194AD9FFFFFFF
              ]} ==
               H3Geo.polygon_to_cells(polygon, 6)
    end

    test "it returns any covering cells for a small polygon" do
      polygon =
        File.read!(Path.join(__DIR__, "support/small_polygon.geojson"))
        |> Jason.decode!()
        |> Geo.JSON.decode!()

      assert {:ok,
              [
                0x86194E59FFFFFFF,
                0x86194E597FFFFFF,
                0x86195D96FFFFFFF
              ]} ==
               H3Geo.polygon_to_cells(polygon, 6)
    end

    test "it errors with an empty line string" do
      polygon = %Geo.Polygon{coordinates: [[]]}

      assert {:error, :invalid_geometry} == H3Geo.polygon_to_cells(polygon, 6)
    end
  end

  describe "multipolygon_to_cells/2" do
    test "it returns the correct cells" do
      multipolygon =
        File.read!(Path.join(__DIR__, "support/multipolygon.geojson"))
        |> Jason.decode!()
        |> Geo.JSON.decode!()

      expected_cells = [
        0x8409A4DFFFFFFFF,
        0x8409A41FFFFFFFF,
        0x8409A45FFFFFFFF,
        0x84192CBFFFFFFFF,
        0x8409A47FFFFFFFF,
        0x8409A43FFFFFFFF,
        0x8409A09FFFFFFFF,
        0x8409A6BFFFFFFFF,
        0x8409A69FFFFFFFF,
        0x8409A55FFFFFFFF
      ]

      assert {:ok, returned_cells} = H3Geo.multipolygon_to_cells(multipolygon, 4)
      assert expected_cells == returned_cells
    end

    test "it errors with an empty line string" do
      polygon = %Geo.MultiPolygon{coordinates: [[[]]]}

      assert {:error, :invalid_geometry} == H3Geo.multipolygon_to_cells(polygon, 6)
    end
  end

  describe "compact/1 and uncompact/2" do
    test "works forward and back" do
      cells =
        [
          0x86195DADFFFFFFF,
          0x86195D377FFFFFF,
          0x86195D367FFFFFF,
          0x86195DACFFFFFFF,
          0x86195D347FFFFFF,
          0x86195D36FFFFFFF,
          0x86194AD97FFFFFF,
          0x86194AD9FFFFFFF
        ]
        |> Enum.sort()

      assert {:ok, compacted} = H3Geo.compact(cells)
      assert {:ok, ^cells} = H3Geo.uncompact(compacted, 6)
    end
  end

  describe "cell_to_boundary/1" do
    test "it returns the correct boundary coordinates" do
      cell = 0x86195985FFFFFFF

      assert {:ok, coordinates} = H3Geo.cell_to_boundary(cell)
      assert is_list(coordinates)
      assert length(coordinates) > 0

      # Each coordinate should be a tuple of {lng, lat}
      Enum.each(coordinates, fn coord ->
        assert is_tuple(coord)
        assert tuple_size(coord) == 2
        {lng, lat} = coord
        assert is_float(lng)
        assert is_float(lat)
      end)
    end

    test "it errors with an invalid cell index" do
      assert {:error, :invalid_cell_index} == H3Geo.cell_to_boundary(0)
    end
  end
end
