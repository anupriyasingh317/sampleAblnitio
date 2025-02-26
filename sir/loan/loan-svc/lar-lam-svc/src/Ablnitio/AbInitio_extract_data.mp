# Ab Initio Graph for Data Extraction
graph extract_data
{
    # Define your extraction components
    input_file("source_data.txt") {
        out0("id", "data_value");
    }

    output_table("raw_data") {
        in0("id", "data_value");
    }

    # Connect components
    input_file.out0 -> output_table.in0;
}