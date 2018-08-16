-- Connecting trail segments that should be connected, and appear connected
-- It can be tricky to find the spot where trail segments almost, but don't quite, connect

--set the version
exec sde.set_current_version 'dbo.tqc';
--Find out how many segments of FEATUREID are not connected (starting with the longest segment) 
select dbo.TrailsNotConnected('{5158CB16-26AD-4AFF-B87F-49305F242E47}')
-- If there is only one, get the coordinate of the first vertex
select dbo.TrailNotConnected('{5158CB16-26AD-4AFF-B87F-49305F242E47}').STAsText()
-- If there are more than one, then first see how many segments are part of the FEATUREID to figure out how many are not connected
-- if there are only a few not connected, get the starting vertex of a random unconnected segement - maybe that will tie it all together
Select count(*) from gis.TRAILS_LN_evw where featureid = '{5158CB16-26AD-4AFF-B87F-49305F242E47}'
Select Top 1 geometryid from gis.TRAILS_LN_evw where featureid = '{5158CB16-26AD-4AFF-B87F-49305F242E47}' order by shape.STLength() desc;
-- Otherwise, you can start with the geometryid of the longest segment, and one that should be touching to see if they are
-- 1 = touching, 0 = not touching.
select t1.shape.STIntersects(t2.shape) from gis.TRAILS_LN_evw as t1 join gis.TRAILS_LN_evw as t2 on t1.FEATUREID = t2.FEATUREID
where t1.GEOMETRYID = '{5347EF0D-52EF-4092-A7BA-C48917092E8D}' and t2.GEOMETRYID = '{67B86D95-B6C4-415E-BDE8-049F718DB021}'
