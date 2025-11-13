import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/event/models/address_model.dart';
import 'package:get/get.dart';

import '../../event/models/geopoint_model.dart';
import '../../event/models/location_model.dart';
import '../models/partner_recycling_center_model.dart';

class RecyclingCenterManagementScreen extends StatefulWidget {
  const RecyclingCenterManagementScreen({super.key});

  @override
  State<RecyclingCenterManagementScreen> createState() => _RecyclingCenterManagementScreenState();
}

class _RecyclingCenterManagementScreenState extends State<RecyclingCenterManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<PartnerRecyclingCenter> _centers = [];

  /// 添加示例回收中心到 Firestore
  Future<void> _addSampleCenter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 创建示例回收中心
      final center = PartnerRecyclingCenter.createNew(
        name: 'Green Recycling Center ${DateTime.now().millisecondsSinceEpoch}',
        email: 'contact@greenrecycling.com',
        phoneNo: '0123456789',
        website: 'https://greenrecycling.com',
        centerLocation: Location(
          geoPoint: GeoPointModel(latitude: 3.1390, longitude: 101.6869),
          address: Address(unitNo: '23', area: 'Pinang Tunggala', postcode: '13210', city: 'Kepala Batas', state: 'Pulau Pinang', fullAddress: '23, Pinang Tunggal, 13210 Kepala Batas, Pulau Pinang'),
        ),
        image: 'https://example.com/recycling-center.jpg',
        openingHours: {
          'periods': [
            {
              'open': {'day': 0, 'time': '0800'}, // 周日 8:00 AM
              'close': {'day': 0, 'time': '1800'}, // 周日 6:00 PM
            },
            {
              'open': {'day': 1, 'time': '0800'}, // 周一 8:00 AM
              'close': {'day': 1, 'time': '1800'}, // 周一 6:00 PM
            },
            {
              'open': {'day': 2, 'time': '0800'},
              'close': {'day': 2, 'time': '1800'},
            },
            {
              'open': {'day': 3, 'time': '0800'},
              'close': {'day': 3, 'time': '1800'},
            },
            {
              'open': {'day': 4, 'time': '0800'},
              'close': {'day': 4, 'time': '1800'},
            },
            {
              'open': {'day': 5, 'time': '0800'},
              'close': {'day': 5, 'time': '1800'},
            },
            {
              'open': {'day': 6, 'time': '0800'},
              'close': {'day': 6, 'time': '1800'},
            },
          ],
          'weekday_text': [
            'Monday: 8:00 AM – 6:00 PM',
            'Tuesday: 8:00 AM – 6:00 PM',
            'Wednesday: 8:00 AM – 6:00 PM',
            'Thursday: 8:00 AM – 6:00 PM',
            'Friday: 8:00 AM – 6:00 PM',
            'Saturday: 8:00 AM – 6:00 PM',
            'Sunday: 8:00 AM – 6:00 PM',
          ],
        },
        acceptedMaterials: ['Plastic', 'Paper', 'Glass', 'Metal'],
        numberOfStaff: 5,
        status: 'active',
        rating: 4.5,
        userRatingsTotal: 120,
        placeId: 'ChIJP5jIRfdizjERxM0yEoXG2yY',
      );

      // 添加到 Firestore
      final docRef = await _firestore
          .collection('partnerRecyclingCenters')
          .add(center.toJson());

      print('✅ 成功添加回收中心，ID: ${docRef.id}');

      // 重新从数据库获取数据
      await _fetchCentersFromFirestore();

      // 显示成功消息
      Get.snackbar(
        '成功',
        '回收中心已成功添加！',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

    } catch (e) {
      print('❌ 添加回收中心失败: $e');
      Get.snackbar(
        '错误',
        '添加回收中心失败: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 从 Firestore 获取所有回收中心
  Future<void> _fetchCentersFromFirestore() async {
    try {
      final querySnapshot = await _firestore
          .collection('partnerRecyclingCenters')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final centers = querySnapshot.docs.map((doc) {
        return PartnerRecyclingCenter.fromSnapshot(doc);
      }).toList();

      setState(() {
        _centers = centers;
      });

      print('✅ 成功获取 ${centers.length} 个回收中心');
    } catch (e) {
      print('❌ 获取回收中心失败: $e');
      Get.snackbar(
        '错误',
        '获取回收中心失败: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// 刷新数据
  Future<void> _refreshData() async {
    await _fetchCentersFromFirestore();
  }

  /// 初始化时获取数据
  @override
  void initState() {
    super.initState();
    _fetchCentersFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '回收中心管理',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 刷新按钮
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新数据',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和说明
            const Text(
              '回收中心管理',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '添加示例回收中心到数据库，并查看实时显示效果',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // 添加按钮
            ElevatedButton(
              onPressed: _isLoading ? null : _addSampleCenter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '添加示例回收中心',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 数据统计
            Row(
              children: [
                _buildStatCard(
                  '总计',
                  _centers.length.toString(),
                  Icons.recycling,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  '活跃',
                  _centers.where((c) => c.isActive).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  '营业中',
                  _centers.where((c) => c.isOpenNow).length.toString(),
                  Icons.access_time,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 列表标题
            Row(
              children: [
                const Text(
                  '回收中心列表',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  label: Text(_centers.length.toString()),
                  backgroundColor: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 数据显示区域
            Expanded(
              child: _buildCentersList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建回收中心列表
  Widget _buildCentersList() {
    if (_centers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.recycling, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              '暂无回收中心数据',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '点击上方按钮添加示例数据',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: _centers.length,
        itemBuilder: (context, index) {
          final center = _centers[index];
          return _buildCenterCard(center);
        },
      ),
    );
  }

  /// 构建回收中心卡片
  Widget _buildCenterCard(PartnerRecyclingCenter center) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 名称和状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    center.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: center.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    center.isActive ? '活跃' : '非活跃',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 联系信息
            _buildInfoRow(Icons.email, center.email),
            _buildInfoRow(Icons.phone, center.formattedPhoneNo),
            _buildInfoRow(Icons.language, center.website),

            const SizedBox(height: 8),

            // 位置信息
            _buildInfoRow(Icons.location_on, center.centerLocation.address.fullAddress!),

            const SizedBox(height: 12),

            // 营业状态和评分
            Row(
              children: [
                // 营业状态
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: center.isOpenNow ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        center.isOpenNow ? Icons.access_time : Icons.access_time_filled,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        center.isOpenNow ? '营业中' : '已关门',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 评分
                if (center.rating != null) ...[
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${center.rating}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${center.userRatingsTotal} 评价)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // 创建时间和员工数量
            Row(
              children: [
                _buildMetaInfo('🕒 ${center.formattedCreatedAt}'),
                const Spacer(),
                _buildMetaInfo('👥 ${center.numberOfStaff} 名员工'),
              ],
            ),

            // 可回收材料
            if (center.acceptedMaterials.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '可回收材料:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: center.acceptedMaterials.map((material) {
                  return Chip(
                    label: Text(material),
                    backgroundColor: Colors.blue[50],
                    labelStyle: const TextStyle(fontSize: 12),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建元信息
  Widget _buildMetaInfo(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }
}