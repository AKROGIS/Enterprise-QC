Facility Attachments
====================
This information is supplemental to the Appendix in the NPS Building Spatial Data Standard, dated 2018-04-10 (https://ir.sharepoint.nps.gov/GIS/DataMgmt/StandardsDocs/Buildings/NPS_BuildingSpatialDataStandard.pdf).

AKR_ATTACH
----------
This non-spatial table is for supplemental information (photos, pdfs, web pages, etc.)
documenting other spatial facility records.  These attachments do not have an explicit
location of their own, rather they can be used with any (or all) location(s) of any
facility in the database.

## Relation to spatial data

Attachments are secondary to a spatial dataset.  Any spatial record
can link to a non-spatial attachment via one of the four following columns:

* FACLOCID
* FACASSETID
* FEATUREID
* GEOMETRYID

These four columns in AKR_ATTACH are foreign keys to the equivalent column in any of
the spatial tables in the facilities database. These columns specify
which facility this attachment supplements.  It is legal to leave all 4 columns
null, but this attachment will never be represented spatially in GIS.
Typically only one of the columns will be used, but it is legal to use more than
one.  There is no attempt to ensure that there is consistency between these columns.
Indeed they can used to link the attachment to 4 different facilities.

If only GEOMETRYID is used, then this attachment will only be linked to that specific
geometry, i.e. a building entrance, but not the center point or footprint.  If
one of the other three fields are used, then all geometries that have the same
value in the equivalent field will be linked this attachment.

There is an implicit assumption that FEATUREID and GEOMETRYID are true GUIDs and
will be unique across all datasets.  If this assumption is violated, then the
attachment may be linked to more facilities than expected.

There is no automated process to ensure that these foreign keys stay consistent with the
spatial records, and it is anticipated that some attachments will become orphaned overtime.
However if they did at one time reference a now deleted facility, then they should still
be linked to that record in the historical archive.

QC processes may check that at least one of these columns contains a valid foreign key,
however failing this check would be a warning, not an error, as discussed above.

The data standard requires "at least one of the following attributes must be
populated for each feature [attachment]: FEATUREID, FACLOCID, or FACASSETID."
However this is not enforced by AKR.  If a user requires strict conformance,
then they can filter out all attachments where all three are null.

## Supplemental columns

Alaska region will also use these additional columns

1. ATCHID - an immutable, non-null, unique, calculated GUID for permanent reference
   to this attachment.
2. ATCHDATE - Required. The date/time when this attachment was created (photo) or
   published (pdf).  The date/time is needed to assess the currency/relevance of the
   attachment, particularly in relation to other attachments for the same facility.
   The time zone is not recorded, so times will be ambiguous.
   As this field is informational, a local time is the AKR assumption and preference.
   However an implementation could standardize on UTC.  The date/time is usually stored
   in the EXIF data of a photo.  You can also use the file creation date if the
   EXIF data is unavailable or questionable.  If an estimate is being made, use 0
   for minutes, 0 for hours, 1 for day, and 1 for month as necessary.
3. ATCHSOURCE - an optional informational text field with a path, URL or description
   of the source of this attachment.  This can be useful metadata for validating
   or updating the data at ATCHLINK.

## Usage in ArcMap

A spatial dataset will need to use 4 joins to ensure all possible
attachments are available.  This can be simplified by creating special views in the
database for selected use cases.

AKR_ATTACH_PT
-------------
This spatial table is for supplemental information (typically a photo) that has
a specific location (and optionally direction and field-of-view).  These attachments
are typically not tied to any specific facility, but are used to document all the
facilities in the field of view at a specific time.  They are also useful for
explicitly documenting what part of a facility is in a photo.

## Usage of select columns

* FACLOCID - Typically not used. A hint about a facility that might be in the photo.
* FACASSETID - Typically not used. A hint about an asset that might be in the photo.
* FEATUREID - Typically not used. A hint about a feature that might be in the photo.
* GEOMETRYID - an immutable, non-null, unique, calculated GUID for permanent reference
  to this attachment.

Note that GEOMETRYID is a primary key for the attachment, while the others are
foreign keys to the subject in the attachment.

The data standard requires "at least one of the following attributes must be
populated for each feature [attachment point]: FEATUREID, FACLOCID, or FACASSETID."
However this is not enforced by AKR.  If a user requires a value, then a spatial query
could be used to find the closest facility (within the field of view for photos).

## Supplemental columns

Alaska region will also use these additional columns

1. ATCHDATE - Required. The date/time when this attachment was created (photo) or
   published (pdf).  The date/time is needed to assess the currency/relevance of the
   attachment, particularly in relation to other attachments for the same facility.
   The time zone is not recorded, so times will be ambiguous.
   As this field is informational, a local time is the AKR assumption and preference.
   However an implementation could standardize on UTC.  The date/time is usually stored
   in the EXIF data of a photo.  You can also use the file creation date if the
   EXIF data is unavailable or questionable.  If an estimate is being made, use 0
   for minutes, 0 for hours, 1 for day, and 1 for month as necessary.
2. ATCHSOURCE - an optional informational text field with a path, URL or description
   of the source of this attachment.  This can be useful metadata for validating
   or updating the data at ATCHLINK.
3. POINTTYPE - from the core data standard.  This must be 'Photo point' when ATCHTYPE = 'Photo'
   It can be 'Photo point' or 'Arbitrary point' for ATCHTYPE <> 'Photo'.
4. ISOUTPARK - a spatially calculated text field. One of 'Yes', 'No', or 'Both' in the unusual
   case that the point is on the border of the park.
5. HEADING - The angle (in clockwise degrees) that the camera is pointed.  Looking north is 0,
   west is 90, etc. This is an optional numeric field. It is typically in EXIF data provide by
   photos taken on mobile devices. If present, it can be used to assign the
   rotation on a directional symbol in a map.
6. HFOV - The horizontal field of view in degrees.  This describes the horizontal extents of
   the photo relative to the HEADING. This is an optional numeric field. This may be available
   in the photo's EXIF data, or calculated from the focal length and horizontal sensor size in
   EXIF.
7. PITCH - An angle (in degrees plus/minus relative to horizontal) that the camera was tilted.
   This is an optional numeric field.  Most cameras do not provide this in the EXIF data, so
   it is typically left null and assumed to be 0 (horizontal)
8. VFOV - The vertical field of view in degrees. This is an optional numeric field. This
   describes the vertical extents of the photo, relative to the PITCH. This may be available
   in the photo's EXIF data, or calculated from the focal length and horizontal sensor size in
   EXIF.
9. ALTITUDE - The altitude of the camera as reported by the GPS sensor in the camera. This will
   typically be in meters above the reference ellipsoid.  If null, it is assumed that the camera
   is about 1.5 meters above ground at the horizontal location.
