import re, os

name_map = {
    # === ODS ===
    'ods_activity_info_full': '活动信息表',
    'ods_activity_rule_full': '活动规则表',
    'ods_base_category1_full': '一级品类表',
    'ods_base_category2_full': '二级品类表',
    'ods_base_category3_full': '三级品类表',
    'ods_base_dic_full': '编码字典表',
    'ods_base_province_full': '省份表',
    'ods_base_region_full': '地区表',
    'ods_base_trademark_full': '品牌表',
    'ods_cart_info_full': '购物车全量表',
    'ods_cart_info_inc': '购物车增量表',
    'ods_comment_info_inc': '评论增量表',
    'ods_coupon_info_full': '优惠券信息表',
    'ods_coupon_use_inc': '优惠券领用增量表',
    'ods_favor_info_inc': '收藏增量表',
    'ods_log_inc': '日志增量表',
    'ods_order_detail_activity_inc': '订单明细活动增量表',
    'ods_order_detail_coupon_inc': '订单明细优惠券增量表',
    'ods_order_detail_inc': '订单明细增量表',
    'ods_order_info_inc': '订单增量表',
    'ods_order_refund_info_inc': '退单增量表',
    'ods_order_status_log_inc': '订单状态日志增量表',
    'ods_payment_info_inc': '支付增量表',
    'ods_promotion_pos_full': '营销坑位表',
    'ods_promotion_refer_full': '营销渠道表',
    'ods_refund_payment_inc': '退款增量表',
    'ods_sku_attr_value_full': 'SKU属性值表',
    'ods_sku_info_full': '商品表',
    'ods_sku_sale_attr_value_full': 'SKU销售属性值表',
    'ods_spu_info_full': 'SPU表',
    'ods_user_info_inc': '用户增量表',
    # === DIM ===
    'dim_activity_full': '活动维度表',
    'dim_coupon_full': '优惠券维度表',
    'dim_date': '日期维度表',
    'dim_promotion_pos_full': '营销坑位维度表',
    'dim_promotion_refer_full': '营销渠道维度表',
    'dim_province_full': '地区维度表',
    'dim_sku_full': '商品维度表',
    'dim_user_zip': '用户维度表',
    # === DWD ===
    'dwd_interaction_favor_add_inc': '互动域收藏加购事实表',
    'dwd_tool_coupon_used_inc': '工具域优惠券使用事实表',
    'dwd_trade_cart_add_inc': '交易域加购事实表',
    'dwd_trade_cart_full': '交易域购物车全量事实表',
    'dwd_trade_order_detail_inc': '交易域订单明细事实表',
    'dwd_trade_pay_detail_suc_inc': '交易域支付成功事实表',
    'dwd_trade_trade_flow_acc': '交易域交易流水累积表',
    'dwd_traffic_page_view_inc': '流量域页面浏览事实表',
    'dwd_user_login_inc': '用户域登录事实表',
    'dwd_user_register_inc': '用户域注册事实表',
    # === DWS ===
    'dws_interaction_sku_favor_add_1d': '互动域SKU收藏近1日汇总表',
    'dws_tool_user_coupon_coupon_used_1d': '工具域用户优惠券使用近1日汇总表',
    'dws_trade_province_order_1d': '交易域省份订单近1日汇总表',
    'dws_trade_province_order_nd': '交易域省份订单近N日汇总表',
    'dws_trade_user_cart_add_1d': '交易域用户加购近1日汇总表',
    'dws_trade_user_order_1d': '交易域用户订单近1日汇总表',
    'dws_trade_user_order_td': '交易域用户订单累积汇总表',
    'dws_trade_user_payment_1d': '交易域用户支付近1日汇总表',
    'dws_trade_user_sku_order_1d': '交易域用户SKU订单近1日汇总表',
    'dws_trade_user_sku_order_nd': '交易域用户SKU订单近N日汇总表',
    'dws_traffic_page_visitor_page_view_1d': '流量域访客页面浏览近1日汇总表',
    'dws_traffic_session_page_view_1d': '流量域会话页面浏览近1日汇总表',
    'dws_user_user_login_td': '用户域用户登录累积汇总表',
    # === ADS ===
    'ads_coupon_stats': '优惠券统计表',
    'ads_new_order_user_stats': '新增下单用户统计表',
    'ads_order_by_province': '地区订单统计表',
    'ads_order_continuously_user_count': '连续下单用户统计表',
    'ads_order_stats_by_cate': '品类订单统计表',
    'ads_order_stats_by_tm': '品牌订单统计表',
    'ads_order_to_pay_interval_avg': '下单到支付时间间隔平均值表',
    'ads_page_path': '页面路径统计表',
    'ads_repeat_purchase_by_tm': '品牌复购率统计表',
    'ads_sku_cart_num_top3_by_cate': 'SKU加购量前三统计表',
    'ads_sku_favor_count_top3_by_tm': 'SKU收藏数前三统计表',
    'ads_traffic_stats_by_channel': '渠道流量统计表',
    'ads_user_action': '用户行为统计表',
    'ads_user_change': '用户变动统计表',
    'ads_user_retention': '用户留存率统计表',
    'ads_user_stats': '用户统计表',
}

def get_layer(fpath):
    parts = fpath.replace(os.sep, '/').split('/')
    for p in parts:
        if p in ('ods','dim','dwd','dws','ads'):
            return p.upper()
    return ''

def fix_header(fpath):
    base = os.path.splitext(os.path.basename(fpath))[0]
    layer = get_layer(fpath)
    cn_name = name_map.get(base, base)

    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Match the old 4-line header pattern
    pattern = r'^-- =+\n-- [A-Z]+ - [^\n]+\n-- 来源: [^\n]+\n-- =+\n?'
    new_header = f'-- ================================================================\n-- {layer} - {base} - {cn_name}\n-- ================================================================\n'

    if re.match(pattern, content, re.MULTILINE):
        content = re.sub(pattern, new_header, content, count=1, flags=re.MULTILINE)
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

count = 0
for root, dirs, files in os.walk('sql'):
    for f in files:
        if f.endswith('.sql'):
            fpath = os.path.join(root, f)
            if fix_header(fpath):
                print(f'  ✓ {fpath}')
                count += 1

print(f'\n共处理 {count} 个文件')
