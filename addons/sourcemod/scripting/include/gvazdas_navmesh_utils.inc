//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.

// v1.01 -- improved constrained logic
// v1.02 -- added navmesh_clip

#if defined _gvazdas_navmesh_utils_inc_included
 #endinput
#endif
#define _gvazdas_navmesh_utils_inc_included

#include <left4dhooks>

#if !defined AREA_COMMON
    #define AREA_COMMON 1024.0 // how much xy area a common infected takes up 
    #define SIDE_COMMON 32.0
#endif

#if !defined DEBUG
    #define DEBUG 0
#endif

// Project given xy coordinates onto navArea (get Z automatically). return false on failure. force_OOB ignores OOB prevention
stock bool project_navmesh_xy(Address navArea, float pos[3], bool force_OOB = false)
{
    if (navArea == Address_Null) return false;
    if (!force_OOB && navmesh_OOB(navArea,pos,false)) return false;
    pos[2] = L4D_NavArea_GetZ(navArea,pos);
    return true;
}

// get navArea size vector relevant for spawning; extends any xy component shorter than min to min
stock void L4D_GetNavAreaSpawnSize(Address navArea, float size[3], float min = 32.0)
{
    L4D_GetNavAreaSize(navArea,size); AbsoluteVector(size);
    if (min>0.0)
    {
        if (size[0] < min) size[0] = min;
        if (size[1] < min) size[1] = min;
    }
}

// Calculate how many commons we can fit in the given navArea xy bounds
stock float nav_xy_area(Address navArea, float min = 32.0)
{
    static float size[3];
    L4D_GetNavAreaSpawnSize(navArea,size,min);
    return vec_xy_area(size);
}

stock float vec_xy_area(const float v[3])
{
    return v[0]*v[1];
}

// Check if position is out of bounds for given navmesh in xy plane. z=true to check if z is under
stock bool navmesh_OOB(const Address navArea, float pos[3], const bool z = true)
{
    if (navArea == Address_Null) return true;
    static float center[3],size[3];
    L4D_GetNavAreaCenter(navArea,center);
    L4D_GetNavAreaSize(navArea,size); AbsoluteVector(size);
    if (z && pos[2]<L4D_NavArea_GetZ(navArea,pos)) return true;
    static float mins[3], maxs[3]; get_center_size_mins_maxs(center,size,mins,maxs);
    return pos_OOB(pos,mins,maxs,false);
}

// clip_xy for navmesh
stock void navmesh_clip(const Address navArea, float pos[3])
{
    if (navArea == Address_Null) return;
    static float center[3],size[3];
    L4D_GetNavAreaCenter(navArea,center);
    L4D_GetNavAreaSize(navArea,size); AbsoluteVector(size);
    static float mins[3], maxs[3]; get_center_size_mins_maxs(center,size,mins,maxs);
    clip_xy(pos,mins,maxs);
    pos[2] = L4D_NavArea_GetZ(navArea,pos);
}

// get mins and maxs for given center and abs size
stock void get_center_size_mins_maxs(const float center[3], const float size[3], float mins[3], float maxs[3])
{
    static float half[3];
    half = size; ScaleVector(half,0.5);
    AddVectors(center,half,maxs);
    SubtractVectors(center,half,mins);
}

// Check if pos is out of bounds with respect to mins or maxs. z=true for xyz, z=false for xy
stock bool pos_OOB(const float pos[3], const float mins[3], const float maxs[3], const bool z = false)
{
    if (pos[0]<mins[0] || pos[0]>maxs[0] || pos[1]<mins[1] || pos[1]>maxs[1]) return true;
    if (z && pos[2]<mins[2]) return true;
    return false;
}

// Take abs of each vector component, modify in-place
stock void AbsoluteVector(float v[3])
{
    v[0] = FloatAbs(v[0]);
    v[1] = FloatAbs(v[1]);
    v[2] = FloatAbs(v[2]);
}

stock void clip_xy(float pos[3], const float mins[3], const float maxs[3])
{
    if (pos[0]<mins[0]) pos[0] = mins[0];
    else if (pos[0]>maxs[0]) pos[0] = maxs[0];
    if (pos[1]<mins[1]) pos[1] = mins[1];
    else if (pos[1]>maxs[1]) pos[1] = maxs[1];
}

#define ADJACENT_TOO_FAR_SQ 20000.0

// Check if two connected navmeshes are reasonably close. 
stock bool navmesh_adjacent_too_far(Address from, Address to)
{
    if (from == Address_Null || to == Address_Null) return false;
    static float center_from[3], center_to[3], size_from[3], size_to[3], vGap[3];
    L4D_GetNavAreaCenter(from,center_from); L4D_GetNavAreaCenter(to,center_to);
    //float dist_centers = GetVectorDistance({0.0,0.0,center_from[2]},{0.0,0.0,center_to[2]},true);
    //if (dist_centers>500000.0) return true;
    center_from[2] = 0.0; center_to[2] = 0.0;
    float dist_centers = GetVectorDistance(center_from,center_to,true);
    if (dist_centers<ADJACENT_TOO_FAR_SQ) return false;
    L4D_GetNavAreaSize(from,size_from); L4D_GetNavAreaSize(to,size_to);
    vGap[0] = FloatAbs(center_to[0]-center_from[0]) - size_from[0]/2.0 - size_to[0]/2.0;
    if (vGap[0]<0.0) vGap[0] = 0.0;
    vGap[1] = FloatAbs(center_to[1]-center_from[1]) - size_from[1]/2.0 - size_to[1]/2.0;
    if (vGap[1]<0.0) vGap[1] = 0.0;
    float gap = GetVectorLength(vGap,true);
    if (gap>=ADJACENT_TOO_FAR_SQ)
    {
        #if DEBUG>1
        LogMessage("navmesh_adjacent_too_far %.1f", gap);
        #endif
        return true;
    }
    return false;
}

// Check if navmesh is too far from given position to be considered "adjacent"
stock bool navmesh_xy_too_far(Address from, const float pos[3])
{
    if (from == Address_Null) return false;
    static float center_from[3], center_to[3], size_from[3], vGap[3];
    L4D_GetNavAreaCenter(from,center_from); center_from[2] = 0.0;
    center_to = pos; center_to[2] = 0.0;
    float dist_centers = GetVectorDistance(center_from,center_to,true);
    if (dist_centers<ADJACENT_TOO_FAR_SQ) return false;
    L4D_GetNavAreaSize(from,size_from);
    vGap[0] = FloatAbs(center_to[0]-center_from[0]) - size_from[0]/2.0;
    if (vGap[0]<0.0) vGap[0] = 0.0;
    vGap[1] = FloatAbs(center_to[1]-center_from[1]) - size_from[1]/2.0;
    if (vGap[1]<0.0) vGap[1] = 0.0;
    float gap = GetVectorLength(vGap,true);
    if (gap>=ADJACENT_TOO_FAR_SQ)
    {
        #if DEBUG>1
        LogMessage("navmesh_xy_too_far %.1f", gap);
        #endif
        return true;
    }
    return false;
}

// Find random pos on large navArea, preferably centered around spawner_pos, for given count of common zombies
stock void L4D_FindRandomSpot_Constrained(const Address navArea, float spawner_pos[3], const int count, float pos[3])
{
    if (count<=1)
    {
        if (navmesh_OOB(navArea,spawner_pos))
        {
            L4D_FindRandomSpot(navArea,pos);
            return;
        }
        pos = spawner_pos;
        return;
    }
    static float mins_cached[3], maxs_cached[3], spawner_pos_cached[3];
    static Address navArea_cached;
    static int count_cached;
    static bool constrained_too_small, constrained_fail;
    static float center[3], size[3], size_spawn[3], mins[3], maxs[3], diff[3];
    static float desired_area, area_full, desired_side;
    bool changed = false;
    if (navArea!=navArea_cached)
    {
        L4D_GetNavAreaCenter(navArea,center); L4D_GetNavAreaSpawnSize(navArea,size_spawn); L4D_GetNavAreaSize(navArea,size);
        diff = size_spawn; diff[2] = 0.0; AbsoluteVector(diff);
        area_full = vec_xy_area(diff); // full spawning size of navArea
        get_center_size_mins_maxs(center,size,mins,maxs); // bounds of navArea
        navArea_cached = navArea; changed = true;
    }
    if (count!=count_cached)
    {
        desired_area = AREA_COMMON*(count+1)*1.25;
        desired_side = SquareRoot(desired_area); // length of ideal square
        count_cached = count; changed = true;
    }
    if (changed) constrained_too_small = area_full<desired_area;
    if ( !constrained_too_small && ( changed || spawner_pos[0]!=spawner_pos_cached[0] || spawner_pos[1]!=spawner_pos_cached[1] ) )
    {
        static float half_size[3];
        half_size[0] = desired_side / 2.0;
        half_size[1] = desired_side / 2.0;
        build_clipped_box(spawner_pos,half_size,mins,maxs,mins_cached,maxs_cached);
        float size_x = maxs_cached[0]-mins_cached[0]; // actual size after clip
        float size_y = maxs_cached[1]-mins_cached[1]; // actual size after clip
        float length_missing;
        if (size_x<desired_side && size[0]>size_x) // Space available along x
        {
            length_missing = desired_side-size_x;
            if (maxs_cached[0]<maxs[0]) { maxs_cached[0] += length_missing; clip_xy(maxs_cached,mins,maxs);}
            else if (mins_cached[0]>mins[0]) { mins_cached[0] -= length_missing; clip_xy(mins_cached,mins,maxs);}
            size_x = maxs_cached[0]-mins_cached[0];
        }
        if (size_y<desired_side && size[1]>size_y) // Space available along y
        {
            length_missing = desired_side-size_y;
            if (maxs_cached[1]<maxs[1]) { maxs_cached[1] += length_missing; clip_xy(maxs_cached,mins,maxs);}
            else if (mins_cached[1]>mins[1]) { mins_cached[1] -= length_missing; clip_xy(mins_cached,mins,maxs);}
            size_y = maxs_cached[1]-mins_cached[1];
        }
        float final_area = clipped_box_xy_Spawnarea(mins_cached,maxs_cached) + 1.0;
        constrained_fail = final_area<desired_area;
        while (constrained_fail)
        {
            if (maxs_cached[0]<maxs[0] || mins_cached[0]>mins[0]) // Space available along x
            {
                length_missing = desired_area/size_y - size_x;
                if (maxs_cached[0]<maxs[0]) { maxs_cached[0] += length_missing; clip_xy(maxs_cached,mins,maxs);}
                else if (mins_cached[0]>mins[0]) { mins_cached[0] -= length_missing; clip_xy(mins_cached,mins,maxs);}
            }
            else if (maxs_cached[1]<maxs[1] || mins_cached[1]>mins[1]) // Space available along y
            {
                length_missing = desired_area/size_x - size_y;
                if (maxs_cached[1]<maxs[1]) { maxs_cached[1] += length_missing; clip_xy(maxs_cached,mins,maxs);}
                else if (mins_cached[1]>mins[1]) { mins_cached[1] -= length_missing; clip_xy(mins_cached,mins,maxs);}
            }
            final_area = clipped_box_xy_Spawnarea(mins_cached,maxs_cached) + 1.0;
            constrained_fail = final_area<desired_area;
            break;
        }
        spawner_pos_cached = spawner_pos;
    }
    if (constrained_too_small || constrained_fail)
    {
        L4D_FindRandomSpot(navArea,pos);
        return;
    }
    pos[0] = GetRandomFloat(mins_cached[0],maxs_cached[0]);
    pos[1] = GetRandomFloat(mins_cached[1],maxs_cached[1]);
    pos[2] = L4D_NavArea_GetZ(navArea,pos) + 1.0;
}

// In-place re-order pos1 and pos2 so that pos1 is closer to start.
stock void SortTwoVectorsClosest(const float start[3], float pos1[3], float pos2[3])
{
    float dist1 = GetVectorDistance(start,pos1,true);
    float dist2 = GetVectorDistance(start,pos2,true);
    static float pos_close[3], pos_far[3];
    if (dist1>dist2)
    {
        pos_close = pos2;
        pos_far = pos1;
    }
    else
    {
        pos_close = pos1;
        pos_far = pos2;
    }
    pos1 = pos_close;
    pos2 = pos_far;
}

// Build mins_out and maxs_out, centered around center clipped by mins and maxs
stock void build_clipped_box(const float center[3], const float half[3], const float mins[3], const float maxs[3], float mins_out[3], float maxs_out[3])
{
    AddVectors(center,half,maxs_out);
    SubtractVectors(center,half,mins_out);
    clip_xy(mins_out,mins,maxs); clip_xy(maxs_out,mins,maxs);
}

stock float clipped_box_xy_Spawnarea(const float mins[3], const float maxs[3], const float min = 32.0)
{
    static float diff[3];
    SubtractVectors(maxs,mins,diff); AbsoluteVector(diff);
    if (min>0.0)
    {
        if (diff[0] < min) diff[0] = min;
        if (diff[1] < min) diff[1] = min;
    }
    return vec_xy_area(diff);
}