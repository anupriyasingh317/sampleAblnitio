# Ab Initio Graph for Data Processing
graph process_data
{
    # Define your input and output components
    input_table("raw_data") {
        out0("id", "data_value");
    }

    transform("process_data") {
        in0("id", "data_value");
        out0("id", "processed_value");
        out0 <- in0;
        out0.processed_value <- in0.data_value + " processed";
    }

    output_table("processed_data") {
        in0("id", "processed_value");
    }

    # Connect components
    input_table.out0 -> transform.in0;
    transform.out0 -> output_table.in0;
}