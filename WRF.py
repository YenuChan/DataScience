# ============ 1. 导入 ============
import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns


# ============ 2. 中文显示（★ 不写这一行，所有中文都会变成方块 ▯）============
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei']   # 微软雅黑，Windows 自带
plt.rcParams['axes.unicode_minus'] = False              # 负号不要显示成方块


# ============ 3. 显示设置（可选，让 DataFrame 打印更好看）============
pd.set_option('display.max_columns', 50)     # 最多显示 50 列
pd.set_option('display.max_rows', 60)        # 最多显示 60 行，超出用 ... 省略
pd.set_option('display.width', 150)          # 一行最多 150 字符，避免折行


# ============ 4. 环境自检（跑一遍确认没问题）============
def check_env():
    print('=' * 52)
    print('pandas     ', pd.__version__)
    print('numpy      ', np.__version__)
    print('matplotlib ', matplotlib.__version__)
    print('seaborn    ', sns.__version__)
    fonts = {f.name for f in matplotlib.font_manager.fontManager.ttflist}
    ok = 'Microsoft YaHei' in fonts
    print('中文字体     Microsoft YaHei ->', '可用' if ok else '不可用（要换别的字体）')
    print('=' * 52)
    return ok


#if __name__ == '__main__':
    check_env()


# ============ 5. 常用写法速查（用的时候取消注释）============
#
#   df = pd.read_csv('data.csv', encoding='utf-8-sig')
#   df.info()                        # 列名 / 类型 / 非空数
#   df.head()                        # 前 5 行
#   df.isnull().sum()                # 每列缺失值个数
#
#   df[df['price'] > 100]                     # 布尔索引
#   df.query('price > 100 and city == "北京"')  # 更像 SQL 的写法
#   df.loc[0:2, ['city', 'price']]             # 按标签取
#   df.iloc[0:2, 0:2]                          # 按位置取
#
#   df.groupby('city')['price'].mean()          # 每组均值（Series）
#   df.groupby('city')[['price']].mean()        # 每组均值（DataFrame）
#   df.groupby('city').agg({'price': ['sum', 'mean']})
#
#   pd.merge(a, b, on='id', how='left')        # 等价 SQL LEFT JOIN
#   pd.concat([a, b], ignore_index=True)       # 等价 UNION ALL
#
#   plt.figure(figsize=(8, 4.5))
#   df.plot(kind='bar', x='city', y='price')
#   plt.title('各城市价格')
#   plt.tight_layout()
#   plt.show()                                  # Jupyter 里可省略
#   # plt.savefig('out.png', dpi=130, bbox_inches='tight')   # 存文件
df = pd.read_csv(r'C:\Users\51324\Desktop\学习资料\CSC3170\RFM\rfm_原始数据.csv', encoding='utf-8-sig')
df=df.replace('',np.nan)
df=df.dropna()
df=df[df['customer']!='TEST001']
df = df.drop_duplicates()
df['customer']=df['customer'].str.strip().str.upper()
df=df.dropna(subset=['amount','customer','order_date'])
df['amount'] = pd.to_numeric(df['amount'].astype(str).str.replace('¥', '', regex=False)
            .str.replace(',', '', regex=False),
            errors='coerce')
df=df[df['amount']>0]
df['order_date'] = pd.to_datetime(df['order_date'], format='mixed')
now=max(df['order_date'])+pd.Timedelta(days=1)
fdf=df.groupby(['customer']).agg(M=('amount','sum'),
                                 F=('customer','count'),
                                 R=('order_date', lambda x: (now - max(x)).days))
# ===== 自查开始 =====
#print('行数      ', len(df),                    ' 应为 48')
#print('客户数    ', df['customer'].nunique(),    ' 应为 14')
#print('amount 类型', df['amount'].dtype,          ' 应为 float64')
#print('日期类型  ', df['order_date'].dtype,       ' 应为 datetime64')
#print('重复行    ', int(df.duplicated().sum()),   ' 应为 0')
#print('缺失总数  ', int(df.isna().sum().sum()),   ' 应为 0')
#print('负数金额  ', int((df['amount'] < 0).sum()), ' 应为 0')
#print('TEST 账号 ', int(df['customer'].str.startswith('TEST').sum()), ' 应为 0')
#print('日期范围  ', df['order_date'].min().date(), '~', df['order_date'].max().date())

#NOW = df['order_date'].max() + pd.Timedelta(days=1)
#print('NOW       ', NOW.date(), ' 应为 2024-11-24')

#rfm = df.groupby('customer').agg(
#    最近下单=('order_date', 'max'),
#    下单次数=('customer', 'count'),
#    消费总额=('amount', 'sum'),
#)
#rfm['R'] = (NOW - rfm['最近下单']).dt.days
#print(rfm[['R', '下单次数', '消费总额']].to_string())
# ===== 自查结束 =====
fdf['F_label']=pd.cut(fdf['F'],[0,2,5,8],labels=[1,2,3])
fdf['R_label']=pd.cut(fdf['R'],3,labels=[3,2,1])
fdf['M_label']=pd.cut(fdf['M'],3,labels=[1,2,3])
fdf['积分'] = fdf[['R_label', 'F_label', 'M_label']].sum(axis=1)
fdf['F_label']=fdf['F_label'].astype(str)
fdf['M_label']=fdf['M_label'].astype(str)
fdf['R_label']=fdf['R_label'].astype(str)
fdf['score']=fdf['F_label']+fdf['M_label']+fdf['R_label']
#================================================
pr = fdf['积分']
w = fdf.index
s = pr.sort_values(ascending=False)
plt.figure(figsize=(12, 5))
plt.bar(w,pr, color='#4C78A8')
plt.title('各客户积分（从高到低）')
plt.xlabel('客户')
plt.ylabel('积分')
plt.xticks(rotation=45)
plt.grid(True, axis='y', alpha=0.3)
plt.show()