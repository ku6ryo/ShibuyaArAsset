Shader "Custom/VolonoiEmergeVertical"
{
  Properties
  {
      _MainTex ("Texture", 2D) = "white" {}
      _Color("Color", Color) = (1, 1, 1, 1)
      _CellSize ("Cell Size", Range(0, 30)) = 2
      _Threshold ("Threshold", Range(-50, 50)) = 0
  }
  SubShader
  {
      Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
      Blend SrcAlpha OneMinusSrcAlpha 
      LOD 100

     Pass {

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"

        static const float TRANSPARENT_MERGIN = 5;

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
            float4 worldPos: TEXCOORD1;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        fixed4 _Color;
        float _CellSize;
        float _Threshold;

      float rand3dTo1d(float3 value, float3 dotDir = float3(12.9898, 78.233, 37.719)){
        //make value smaller to avoid artefacts
        float3 smallValue = sin(value);
        //get scalar value from 3d vector
        float random = dot(smallValue, dotDir);
        //make value more random by making it bigger and then taking the factional part
        random = frac(sin(random) * 143758.5453);
        return random;
      }

      float3 rand3dTo3d(float3 value){
        return float3(
          rand3dTo1d(value, float3(12.989, 78.233, 37.719)),
          rand3dTo1d(value, float3(39.346, 11.135, 83.155)),
          rand3dTo1d(value, float3(73.156, 52.235, 09.151))
        );
      }

      float4 voronoiNoise(float3 value){
        float3 baseCell = floor(value);
        float minDistToCell = 10;
        float3 closestCell;
        [unroll]
        for(int x=-1; x<=1; x++){
            [unroll]
            for(int y=-1; y<=1; y++){
              [unroll]
              for(int z=-1; z<=1; z++){
                float3 cell = baseCell + float3(x, y, z);
                float3 cellPosition = cell + rand3dTo3d(cell);
                float3 toCell = cellPosition - value;
                float distToCell = length(toCell);
                if(distToCell < minDistToCell){
                    minDistToCell = distToCell;
                    closestCell = cell;
                }
              }
            }
        }
        float random = rand3dTo1d(closestCell);
        return float4(closestCell, random);
      }

      v2f vert (appdata v)
      {
          v2f o;
          o.vertex = UnityObjectToClipPos(v.vertex);
          o.uv = TRANSFORM_TEX(v.uv, _MainTex);
          o.worldPos = mul(unity_ObjectToWorld, v.vertex);
          return o;
      }

      fixed4 frag (v2f i) : SV_Target
      {
          float3 value = i.worldPos.xyz / _CellSize;
          float4 volonoi = voronoiNoise(value);
          fixed4 col = tex2D(_MainTex, i.uv) * _Color;
          float y = volonoi.y + volonoi.w;
          if (y < _Threshold) {
            float a = (_Threshold - y) / 3;
            if (a > 1) {
              a = 1;
            }
            col.a = a;
          } else {
            col.a = 0;
          }
          return col;
      }
      ENDCG
    }
  }
  FallBack "Diffuse"
}
