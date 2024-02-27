For security reasons, the structure of your data must contain only the
columns listed below. The presence of any other column, including empty
ones, will result in an error.

-   `group`: The column name must match. This column is optional and is
    used to differentiate your data in the plots.
-   `sample`: The column name must match. This column is optional and is
    used to give each data point a name/ID.
-   `latitude`: The column name must start with “lat”. This column is
    optional but if provided, the column `longitude` must be provided as
    well. This column must contain the latitude part of the geographic
    coordinates as decimal value.
-   `longitude`: The column name must start with “long” or “lng”. This
    column is optional but if provided, the column `latitude` must be
    provided as well. This column must contain the latitude part of the
    geographic coordinates as decimal value.
-   Pb isotope ratios:
    -   Supported ratios are: <sup>204</sup>Pb-normalised ratios,
        <sup>206</sup>Pb-normalised ratios,
        <sup>206</sup>Pb/<sup>207</sup>Pb, and
        <sup>208</sup>Pb/<sup>207</sup>Pb
    -   Column names must contain at least the last number of the
        isotopes’ atomic masses in the correct order. For example, valid
        column names for the ratio <sup>208</sup>Pb/<sup>207</sup>Pb
        are: `8/7`, `208Pb/207Pb`, `208/207`, `Pb208_Pb207`, `208_7Pb`,
        `208.207`. However, “7\_8” or any variant of it would throw an
        error, because the isotope ratio
        <sup>207</sup>Pb/<sup>208</sup>Pb is not supported.
    -   All columns are optional and any missing ratios will be
        automatically calculated from the provided values. If, for
        examples, only <sup>204</sup>Pb-normalised ratios are included,
        the <sup>206</sup>Pb-normalised ratios will be calculated by the
        app.
    -   To make full use of the app, provide any combination that allows
        the calculation of all other ratios. For example, if only the
        isotope ratios <sup>207</sup>Pb/<sup>206</sup>Pb and
        <sup>208</sup>Pb/<sup>206</sup>Pb are uploaded, no isotope
        ratios with <sup>204</sup>Pb can be calculated.

After upload, the uploaded data is checked for consistency. If a check
does not succeed, an error will be thrown in the “Data viewer” tab:

-   “A problem occurred while parsing your file. Please chose the
    appropriate parameters for reading your data.” <br> Explanation: The
    uploaded file was not identified as a table, i.e. rows have
    different numbers of columns or the file contains less than two
    columns. The most likely cause is that you picked the wrong
    separator. Choose another separator. If the error persists, revise
    your file in a text editor and upload it again.
-   “One or more columns in your data set are not supported by
    GlobaLID…” <br> Explanation: The uploaded file contains columns
    other than the permitted ones or at least one column in your file
    does not adhere to the naming conventions for columns names outlined
    above. Revise the column names in your file and upload it again.
-   “Columns for isotope ratios must contain only numeric values.” <br>
    Explanation: Values in at least one column for isotope ratios were
    not recognised as numbers. The reason might be that you picked the
    wrong decimal sign, that the values were accidentally saved as text
    before upload or that at least one ratio in a column contains a
    letter. Try setting the upload parameter to the other decimal sign.
    If the error persists, revise the file in a text editor and upload
    it again.
-   “Columns for coordinates must contain only numeric values.” <br>
    Explanation: Values in at least one column for the geographic
    coordinates were not recognised as numbers. The reason might be that
    you picked the wrong decimal sign, that the values were accidentally
    saved as text before upload or that at least one coordinate in a
    column contains a letter. Try setting the upload parameter to the
    other decimal sign. If the error persists, revise the file in a text
    editor and upload it again.
-   “One or more of the latitude coordinates is out of bounds.” | “One
    or more of the longitude coordinates is out of bounds.” <br>
    Explanation: At least one value in the column for the respective
    geographic coordinate is outside the allowed range. Allowed ranges
    are: -90 to 90 for the latitude, -180 and 180 for the longitude.
    Revise the coordinates and upload the file again.
-   “Please provide also the coordinates for the longitude or no
    coordinates at all.” | “Please provide also the coordinates for the
    latitude or no coordinates at all.” <br> Explanation: The uploaded
    files includes only the latitude or longitude. Revise your file by
    either adding a column for the missing coordinate or by removing the
    included coordinate.
